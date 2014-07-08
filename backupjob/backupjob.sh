#!/opt/bin/bash
# script called by cron
source /share/HDA_DATA/backupjob/backupjob.cfg
# Send a mail message
function send_mail() {
	# Takes one optional parameter to indicate error level as subject prefix ($1)
	echo "Sending out notification email. Error level: $1"
	subject="Backup job finished"
	body=/share/HDA_DATA/backupjob/backupjob.log
	timestamp=`date '+%F %T'`

	tmpfile="/tmp/sendmail.tmp"
	/bin/echo -e "Subject:$1 - $subject [$timestamp]\r" > "$tmpfile"
	/bin/echo -e "To: $email_to\r" >> "$tmpfile"
	/bin/echo -e "From: $email_from\r" >> "$tmpfile"
	/bin/echo -e "\r" >> "$tmpfile"
	if [ -f "$body" ]; then
		#cat "$body" >> "$tmpfile"
		tail -50 "$body" >> "$tmpfile"
		/bin/echo -e "\r\n" >> "$tmpfile"
	else
		/bin/echo -e "$body\r\n" >> "$tmpfile"
	fi
	/usr/sbin/sendmail -t < "$tmpfile"
	rm $tmpfile
}
mainlog=/share/HDA_DATA/backupjob/backupjob.log
rsynclog=/share/HDA_DATA/backupjob/backupjob-rsync.log
timestamp_log() { while IFS='' read -r line; do echo "[$(date '+%F %T')] $line" >> "$1"; done; };

#redirect sterr to stdout and then stdout to function
exec 2>&1> >(timestamp_log $mainlog)
echo "Starting backupjob.sh"
#echo "PATH: $PATH"
echo "Config:"
echo "----------------------------------"
echo "rsyncd_hostname=$rsyncd_hostname"
echo "rsyncd_mac=$rsyncd_mac"
echo "email_from=$email_from"
echo "email_to=$email_to"
echo "is_dryrun=$is_dryrun"
echo "----------------------------------"
	 
#example: --skip-compress=gz/jpg/mp[34]/7z/bz2
#default list of suffixes that will not be compressed: 7z avi bz2 deb gz iso jpeg jpg mov mp3 mp4 ogg rpm tbz tgz z zip         
skipzlist="7z/7Z/tbz/tgz/z/zip/ZIP/rar/RAR/bz2/rpm/deb/gz/iso/ISO/jpeg/JPEG/jpg/JPG/avi/AVI/mov/MOV/mkv/MKV/mp[34]/MP[34]/ogg/flac/FLAC/pdf/PDF/bin/BIN/exe/EXE"
if [ -n "${is_dryrun}" ]; then
	dryrun="--dry-run"
fi
dirlist=( "-vrt :/share/HDA_DATA/Public/FOTOS"
		  "-vrtz:/share/HDA_DATA/Public/Documentos"
		  "-vrt :/share/HDA_DATA/Public/PDF"
		  "-vrt :/share/HDA_DATA/Public/MUSICA" )

#######START STUFF
echo "Checking if remote rsync server is already up."
ping -c 1 $rsyncd_hostname
if [ $? -eq 0 ] ; then
	alreadyup=true
fi
if [ -z "${alreadyup}" ]; then
	echo "Host is DOWN. Waking up and waiting 70s..."
	#$rsyncd_hostname - $rsyncd_ip - $rsyncd_mac
	/opt/bin/wakelan -m $rsyncd_mac
	sleep 70
else
	echo "Host IS ALREADY UP! Skipping wake on lan."
fi
#try 15 times to see if rsync server is up
for ((i=1; i<=15; i++)); do                          
	echo -n "Checking if rsyncd is up on port 873 (try #$i)..."
	/opt/bin/nc -z -w 5 $rsyncd_hostname 873                    # Try connecting
	return_code=$?
	if [[ $return_code -eq 0 ]] ; then                # return code 0 is OK, else KO
		echo "Success!"
		echo "Starting rsync tasks"
		if [[ $dryrun ]] ; then
			echo "TRIAL RUN, no changes will be made."
		fi
		exec 2>&1> >(timestamp_log $rsynclog)
		echo "***Starting backupjob.sh rsync tasks."
		exec 2>&1> >(timestamp_log $mainlog)
		error_rc=0
		for item in "${dirlist[@]}" ; do
			option=${item%%:*}
			directory=${item#*:}
			echo "Backing up: $directory"
			exec 2>&1> >(timestamp_log $rsynclog)
			
			echo "***Executing command: /opt/bin/rsync -$option $dryrun --skip-compress=$skipzlist --chmod=ugo=rwX --delete $directory Dani@$rsyncd_hostname::nasbackup"
			/opt/bin/rsync $option $dryrun --skip-compress=$skipzlist --chmod=ugo=rwX --delete "$directory" Dani@$rsyncd_hostname::nasbackup
			
			return_code=$?
			exec 2>&1> >(timestamp_log $mainlog)
			if [[ $return_code -ne 0 ]] ; then
				error_rc=return_code
				echo "Error in rsync task." 
			fi
		done
		exec 2>&1> >(timestamp_log $mainlog)
		error_level=INFO
		if [[ $error_rc -eq 0 ]] ; then
			echo "All rsync tasks finished successfully."
		else
			echo "Some rsync tasks DID NOT finished successfully."
			error_level=ERROR
		fi
		if [ -z "${alreadyup}" ]; then
			echo "Executing remote shutdown on rsync server. Waiting 60s"
			# /usr/bin/ssh rsync@$rsyncd_hostname 'd:\cygwin\bin\shutdown -s 30'
			/usr/bin/ssh rsync@$rsyncd_hostname 'c:\Windows\System32\shutdown /s /t 30 /c "El PC se apagara en 30s, ha terminado la tarea de copia de seguridad"'
			sleep 60
			#try 15 times
			for ((i=1; i<=15; i++)); do                          
				echo "Pinging to check if rsync server is down (try #$i)..."
				exec 2>&1> >(timestamp_log $rsynclog)
				/bin/ping -c 1 $rsyncd_hostname                            # Try pinging 1 times
				return_code=$?
				exec 2>&1> >(timestamp_log $mainlog)
				if [[ $return_code -ne 0 ]] ; then                # return code 1 is reply--> NOK, else OK
					echo "No ping reply. Remote shutdown seems completed."
					send_mail $error_level
					echo "Exit."
					exit 0                        # If okay, flag to exit loop.            
				else
					echo "Got ping replay. Wait 15s before trying again..."
					sleep 15
				fi                
			done
			echo "Still getting ping replies after $((--i)) attempts. Graceful shutdown FAILED"
			echo "Trying force shutdown before giving up"
			/usr/bin/ssh rsync@$rsyncd_hostname 'c:\Windows\System32\shutdown /p /f'
			send_mail ERROR
			echo "Exit."
			exit 2
		else
			echo "Skipping shutdown since host was already up."
			send_mail $error_level
			echo "Exit."
			exit 0
		fi
	else
		echo "FAILED. Wait 15s before trying again..."
		sleep 15
	fi
done
echo "Failed connecting to rsync server after $((--i)) attempts. Giving up."
send_mail FATAL
echo "Exit."
exit 1
