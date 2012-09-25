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
timestamp_log() { while IFS='' read -r line; do echo "$line" >> "$1"; done; };

MAINLOG=/share/HDA_DATA/backupjob/backupjob.log
RSYNCLOG=/share/HDA_DATA/backupjob/backupjob-rsync.log

#example: --skip-compress=gz/jpg/mp[34]/7z/bz2
#my code: --skip-compress=7z/tbz/tgz/z/zip/bz2/rpm/deb/gz/iso/jpeg/jpg/avi/mov/mkv/mp[34]/ogg/flac/pdf/bin/exe
#The default list of suffixes that will not be compressed: 7z avi bz2 deb gz iso jpeg jpg mov mp3 mp4 ogg rpm tbz tgz z zip         
SKIPZLIST="7z/tbz/tgz/z/zip/bz2/rpm/deb/gz/iso/jpeg/jpg/avi/mov/mkv/mp[34]/ogg/flac/pdf/bin/exe"

#DRYRUN="--dry-run"
#COMMANDS[0]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/rsynctest/Asencion Dani@$rsyncd_hostname::rsynctest"
COMMANDS[0]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/FOTOS Dani@$rsyncd_hostname::nasbackup"
COMMANDS[1]="/opt/bin/rsync -vrtz $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/Documentos Dani@$rsyncd_hostname::nasbackup"
COMMANDS[2]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/PDF Dani@$rsyncd_hostname::nasbackup"
COMMANDS[3]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/MUSICA Dani@$rsyncd_hostname::nasbackup"

#exec &> "$MAINLOG"
#exec 2>&1>>"$MAINLOG"
#redirect sterr to stdout and then stdout to function
exec 2>&1> >(timestamp_log $MAINLOG)
echo "Starting backupjob.sh"
echo "PATH: $PATH"
#$rsyncd_hostname - $rsyncd_ip - $rsyncd_mac
echo "Waking remote rsync server up and waiting 30s..."
/opt/bin/wakelan -m $rsyncd_mac
sleep 30
for ((i=1; i<=15; i++)); do                          
    echo -n "Checking if rsyncd is up on port 873 (try #$i)..."
    /opt/bin/nc -z -w 5 $rsyncd_hostname 873                    # Try connecting
    return_code=$?
    if [[ $return_code -eq 0 ]] ; then                # return code 0 is OK, else KO
        echo "Success!"
        echo "Starting rsync tasks"
        error_rc=0
        elements="${#COMMANDS[@]}"
        for (( i=0;i<$elements;i++)); do
            echo "Executing command: ${COMMANDS[${i}]}"
			exec 2>&1> >(timestamp_log $RSYNCLOG)
            eval "${COMMANDS[${i}]}"
			exec 2>&1> >(timestamp_log $MAINLOG)
            return_code=$?
            if [[ $return_code -ne 0 ]] ; then
                error_rc=return_code
                echo "Error in rsync task." 
            fi
        done
        
        error_level=INFO
        if [[ $error_rc -eq 0 ]] ; then
            echo "All rsync tasks finished successfully."
        else
            echo "Some rsync tasks DID NOT finished successfully."
            error_level=ERROR
        fi
        echo "Executing remote shutdown on rsync server. Waiting 60s"
        # /usr/bin/ssh rsync@$rsyncd_hostname 'd:\cygwin\bin\shutdown -s 30'
        /usr/bin/ssh rsync@$rsyncd_hostname 'c:\Windows\System32\shutdown /s /t 30 /c "El PC se apagara en 30s, ha terminado la tarea de copia de seguridad"'
        #/usr/bin/ssh rsync@$rsyncd_hostname 'c:\Windows\System32\shutdown -?'
        sleep 60
        for ((i=1; i<=15; i++)); do                          
            echo "Pinging to check if rsync server is down (try #$i)..."
            /bin/ping -c 1 $rsyncd_hostname                    # Try pinging 1 times
            return_code=$?
            if [[ $return_code -ne 0 ]] ; then                # return code 1 is reply--> NOK, else OK
                echo "Remote shutdown seems completed, no ping reply. Sending notification email..."
                send_mail $error_level
                echo "Done. Exit."
                exit 0                        # If okay, flag to exit loop.            
            else
                echo "Got ping replay. Wait 15s before trying again"
                sleep 15
            fi                
        done
        echo "Still getting ping replies after $((--i)) attempts. Shutdown FAILED. Giving up"
        echo -n "Sending notification email..."
        send_mail ERROR
        echo "Done. Exit."
        exit 2  
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
