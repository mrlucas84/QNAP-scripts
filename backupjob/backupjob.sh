#!/opt/bin/bash
# script called by cron
source /share/CACHEDEV1_DATA/myprograms/backupjob/backupjob.cfg
# Send a mail message
function send_mail() {
	# Takes one optional parameter to indicate error level as subject prefix ($1)
	/bin/echo "Sending out notification email. Error level: $1"
	subject="Backup job finished"
	body=/share/CACHEDEV1_DATA/myprograms/backupjob/backupjob.log
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
mainlog=/share/CACHEDEV1_DATA/myprograms/backupjob/backupjob.log
rsynclog=/share/CACHEDEV1_DATA/myprograms/backupjob/backupjob-rsync.log
#check if link /dev/fd exists
if [ ! -e /dev/fd ]
then
	echo "[$(/bin/date '+%F %T.%3N')] /dev/fd does NOT exist." >> $mainlog
fi
timestamp_log() { while IFS='' read -r line; do /bin/echo "[$(/bin/date '+%F %T.%3N')] $line" >> "$1"; done; };

#redirect sterr to stdout and then stdout to function
exec 2>&1> >(timestamp_log $mainlog)
/bin/echo "Starting backupjob.sh"
#/bin/echo "PATH: $PATH"
/bin/echo "Config:"
/bin/echo "----------------------------------"
/bin/echo "rsyncd_hostname=$rsyncd_hostname"
/bin/echo "rsyncd_mac=$rsyncd_mac"
/bin/echo "email_from=$email_from"
/bin/echo "email_to=$email_to"
/bin/echo "is_dryrun=$is_dryrun"
/bin/echo "----------------------------------"
	 
#example: --skip-compress=gz/jpg/mp[34]/7z/bz2
#default list of suffixes that will not be compressed: 7z avi bz2 deb gz iso jpeg jpg mov mp3 mp4 ogg rpm tbz tgz z zip         
skipzlist="7z/7Z/tbz/tgz/z/zip/ZIP/rar/RAR/bz2/rpm/deb/gz/iso/ISO/jpeg/JPEG/jpg/JPG/avi/AVI/mov/MOV/mkv/MKV/mp[34]/MP[34]/ogg/flac/FLAC/pdf/PDF/bin/BIN/exe/EXE"
if [ -n "${is_dryrun}" ]; then
	dryrun="--dry-run"
fi
dirlist=( "-vrt :/share/CACHEDEV1_DATA/Public/FOTOS"
		  "-vrtz:/share/CACHEDEV1_DATA/Public/Documentos"
		  "-vrt :/share/CACHEDEV1_DATA/Public/PDF"
		  "-vrt :/share/CACHEDEV1_DATA/Public/MUSICA" 
		  "-vrt :/share/CACHEDEV1_DATA/Public/firmware/QNAP/@backup_config" )

#######START STUFF
/bin/echo "Checking if remote rsync server is already up."
/bin/ping -c 1 $rsyncd_hostname
if [ $? -eq 0 ] ; then
	alreadyup=true
fi
if [ -z "${alreadyup}" ]; then
	/bin/echo "Host is DOWN. Waking up and waiting 70s..."
	#$rsyncd_hostname - $rsyncd_ip - $rsyncd_mac
	/opt/bin/etherwake $rsyncd_mac
	sleep 70
else
	/bin/echo "Host IS ALREADY UP! Skipping wake on lan."
fi
#try 15 times to see if rsync server is up
for ((i=1; i<=15; i++)); do                          
	/bin/echo -n "Checking if rsyncd is up on port 873 (try #$i)..."
	/opt/bin/netcat -z -w 5 $rsyncd_hostname 873                    # Try connecting
	return_code=$?
	if [[ $return_code -eq 0 ]] ; then                # return code 0 is OK, else KO
		/bin/echo "Success!"
		/bin/echo "Starting rsync tasks"
		if [[ $dryrun ]] ; then
			/bin/echo "TRIAL RUN, no changes will be made."
		fi
		exec 2>&1> >(timestamp_log $rsynclog)
		/bin/echo "***Starting backupjob.sh rsync tasks."
		exec 2>&1> >(timestamp_log $mainlog)
		error_rc=0
		for item in "${dirlist[@]}" ; do
			option=${item%%:*}
			directory=${item#*:}
			/bin/echo "Backing up: $directory"
			exec 2>&1> >(timestamp_log $rsynclog)
			
			/bin/echo "***Executing command: /usr/bin/rsync -$option $dryrun --skip-compress=$skipzlist --chmod=ugo=rwX --delete $directory Dani@$rsyncd_hostname::nasbackup"
			/usr/bin/rsync $option $dryrun --skip-compress=$skipzlist --chmod=ugo=rwX --delete "$directory" Dani@$rsyncd_hostname::nasbackup
			
			return_code=$?
			exec 2>&1> >(timestamp_log $mainlog)
			if [[ $return_code -ne 0 ]] ; then
				error_rc=return_code
				/bin/echo "Error in rsync task." 
			fi
		done
		exec 2>&1> >(timestamp_log $mainlog)
		error_level=INFO
		if [[ $error_rc -eq 0 ]] ; then
			/bin/echo "All rsync tasks finished successfully."
		else
			/bin/echo "Some rsync tasks DID NOT finished successfully."
			error_level=ERROR
		fi
		if [ -z "${alreadyup}" ]; then
			/bin/echo "Executing remote shutdown on rsync server. Waiting 60s"
			# /usr/bin/ssh rsync@$rsyncd_hostname 'd:\cygwin\bin\shutdown -s 30'
			/usr/bin/ssh rsync@$rsyncd_hostname 'c:\Windows\System32\shutdown /s /t 30 /c "El PC se apagara en 30s, ha terminado la tarea de copia de seguridad"'
			sleep 60
			#try 15 times
			for ((i=1; i<=15; i++)); do                          
				/bin/echo "Pinging to check if rsync server is down (try #$i)..."				
				exec 2>&1> /dev/null
				/bin/ping -q -c 1 $rsyncd_hostname                            # Try pinging 1 times
				return_code=$?
				exec 2>&1> >(timestamp_log $mainlog)
				if [[ $return_code -ne 0 ]] ; then                # return code 1 is reply--> NOK, else OK
					/bin/echo "No ping reply. Remote shutdown seems completed."
					send_mail $error_level
					/bin/echo "Exit."
					exit 0                        # If okay, flag to exit loop.            
				else
					/bin/echo "Got ping replay. Wait 15s before trying again..."
					/bin/sleep 15
				fi                
			done
			/bin/echo "Still getting ping replies after $((--i)) attempts. Graceful shutdown FAILED"
			/bin/echo "Trying force shutdown before giving up"
			/usr/bin/ssh rsync@$rsyncd_hostname 'c:\Windows\System32\shutdown /p /f'
			send_mail ERROR
			/bin/echo "Exit."
			exit 2
		else
			/bin/echo "Skipping shutdown since host was already up."
			send_mail $error_level
			/bin/echo "Exit."
			exit 0
		fi
	else
		/bin/echo "FAILED. Wait 15s before trying again..."
		sleep 15
	fi
done
/bin/echo "Failed connecting to rsync server after $((--i)) attempts. Giving up."
send_mail FATAL
/bin/echo "Exit."
exit 1
