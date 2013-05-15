#!/opt/bin/bash
# script called by cron
# Send a mail message
function send_mail() {
	# Takes one optional parameter to indicate error level as subject prefix
	SUBJECT="Scheduled backup job finished"
	TO=$email_to
	FROM=$email_from
	MSG=/share/HDA_DATA/backupjob/backupjob.log
	TIMESTAMP=`date '+%F %T'`

	TMPFILE="/tmp/sendmail.tmp"
	/bin/echo -e "Subject:[$TIMESTAMP] $1 - $SUBJECT\r" > "$TMPFILE"
	/bin/echo -e "To: $TO\r" >> "$TMPFILE"
	/bin/echo -e "From: $FROM\r" >> "$TMPFILE"
	/bin/echo -e "\r" >> "$TMPFILE"
	if [ -f "$MSG" ]; then
		#cat "$MSG" >> "$TMPFILE"
		tail -50 "$MSG" >> "$TMPFILE"
		/bin/echo -e "\r\n" >> "$TMPFILE"
	else
		/bin/echo -e "$MSG\r\n" >> "$TMPFILE"
	fi
	/usr/sbin/sendmail -t < "$TMPFILE"
	rm $TMPFILE
}
timestamp_log() { while IFS='' read -r line; do echo "[$(date '+%F %T')] $line" >> "$1"; done; };

MAINLOG=/share/HDA_DATA/backupjob/backupjob.log
RSYNCLOG=/share/HDA_DATA/backupjob/backupjob-rsync.log
	 
#example: --skip-compress=gz/jpg/mp[34]/7z/bz2
#my code: --skip-compress=7z/tbz/tgz/z/zip/bz2/rpm/deb/gz/iso/jpeg/jpg/avi/mov/mkv/mp[34]/ogg/flac/pdf/bin/exe
#The default list of suffixes that will not be compressed: 7z avi bz2 deb gz iso jpeg jpg mov mp3 mp4 ogg rpm tbz tgz z zip         
SKIPZLIST="7z/7Z/tbz/tgz/z/zip/ZIP/rar/RAR/bz2/rpm/deb/gz/iso/ISO/jpeg/JPEG/jpg/JPG/avi/AVI/mov/MOV/mkv/MKV/mp[34]/MP[34]/ogg/flac/FLAC/pdf/PDF/bin/BIN/exe/EXE"

DRYRUN="--dry-run"
#COMMANDS[0]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/rsynctest/Asencion Dani@$rsyncd_hostname::rsynctest"
#COMMANDS[0]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/FOTOS Dani@$rsyncd_hostname::nasbackup"
#COMMANDS[1]="/opt/bin/rsync -vrtz $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/Documentos Dani@$rsyncd_hostname::nasbackup"
#COMMANDS[2]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/PDF Dani@$rsyncd_hostname::nasbackup"
#COMMANDS[3]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/MUSICA Dani@$rsyncd_hostname::nasbackup"
#COMMANDS[4]="/opt/bin/rsync -vrtz $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/eBooks Dani@$rsyncd_hostname::nasbackup"

ARRAY=( "-vrt :/share/HDA_DATA/Public/FOTOS"
		"-vrtz:/share/HDA_DATA/Public/Documentos"
		"-vrt :/share/HDA_DATA/Public/PDF"
		"-vrt :/share/HDA_DATA/Public/MUSICA" )

#exec &> "$MAINLOG"
#exec 2>&1>>"$MAINLOG"
#redirect sterr to stdout and then stdout to function
exec 2>&1> >(timestamp_log $MAINLOG)
echo "Starting backupjob.sh"
echo "PATH: $PATH"
echo "Checking if remote rsync server is up."
ping -c 1 $rsyncd_hostname
if [ $? -eq 0 ] ; then
	ISUP=true
else
	ISUP=false
fi

if ! $ISUP; then
	echo "Host is DOWN. Waking up and waiting 70s..."
	#$rsyncd_hostname - $rsyncd_ip - $rsyncd_mac
	/opt/bin/wakelan -m $rsyncd_mac
	sleep 70
else
	echo "Host IS ALREADY UP! Skipping wake on lan"
fi
for ((i=1; i<=15; i++)); do                          
	echo -n "Checking if rsyncd is up on port 873 (try #$i)..."
	/opt/bin/nc -z -w 5 $rsyncd_hostname 873                    # Try connecting
	return_code=$?
	if [[ $return_code -eq 0 ]] ; then                # return code 0 is OK, else KO
		echo "Success!"
		echo "Starting rsync tasks"
		exec 2>&1> >(timestamp_log $RSYNCLOG)
		echo "***Starting backupjob.sh rsync tasks"
		exec 2>&1> >(timestamp_log $MAINLOG)
		error_rc=0
		for item in "${ARRAY[@]}" ; do
			OPTION=${item%%:*}
			DIRECTORY=${item#*:}
			echo "Backing up: $DIRECTORY"
			exec 2>&1> >(timestamp_log $RSYNCLOG)
			
			echo "***Executing command: /opt/bin/rsync -$OPTION $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete $DIRECTORY Dani@$rsyncd_hostname::nasbackup"
			/opt/bin/rsync $OPTION $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete "$DIRECTORY" Dani@$rsyncd_hostname::nasbackup
			
			return_code=$?
			exec 2>&1> >(timestamp_log $MAINLOG)
			if [[ $return_code -ne 0 ]] ; then
				error_rc=return_code
				echo "Error in rsync task." 
			fi
		done
		exec 2>&1> >(timestamp_log $MAINLOG)
		error_level=INFO
		if [[ $error_rc -eq 0 ]] ; then
			echo "All rsync tasks finished successfully."
		else
			echo "Some rsync tasks DID NOT finished successfully."
			error_level=ERROR
		fi
		if ! $ISUP; then
			echo "Executing remote shutdown on rsync server. Waiting 60s"
			# /usr/bin/ssh rsync@$rsyncd_hostname 'd:\cygwin\bin\shutdown -s 30'
			/usr/bin/ssh rsync@$rsyncd_hostname 'c:\Windows\System32\shutdown /s /t 30 /c "El PC se apagara en 30s, ha terminado la tarea de copia de seguridad"'
			sleep 60
			for ((i=1; i<=15; i++)); do                          
				echo "Pinging to check if rsync server is down (try #$i)..."
				exec 2>&1> >(timestamp_log $RSYNCLOG)
				/bin/ping -c 1 $rsyncd_hostname                            # Try pinging 1 times
				return_code=$?
				exec 2>&1> >(timestamp_log $MAINLOG)
				if [[ $return_code -ne 0 ]] ; then                # return code 1 is reply--> NOK, else OK
					echo "No ping reply. Remote shutdown seems completed. Sending notification email..."
					send_mail $error_level
					echo "Done. Exit."
					exit 0                        # If okay, flag to exit loop.            
				else
					echo "Got ping replay. Wait 15s before trying again"
					sleep 15
				fi                
			done
			echo "Still getting ping replies after $((--i)) attempts. Graceful shutdown FAILED"
			echo "Trying force shutdown before giving up"
			/usr/bin/ssh rsync@$rsyncd_hostname 'c:\Windows\System32\shutdown /p /f'
			echo -n "Sending notification email..."
			send_mail ERROR
			echo "Done. Exit."
			exit 2
		else
			echo "Skipping shutdown since host was already up. Sending notification email..."
			send_mail $error_level
			echo "Done. Exit."
			exit 0
		fi
	else
		echo "FAILED. Wait 15s before trying again"
		sleep 15
	fi
done
echo "Failed connecting to rsync server after $((--i)) attempts. Giving up"
echo -n "Sending notification email..."
send_mail FATAL
echo "Done. Exit."
exit 1
