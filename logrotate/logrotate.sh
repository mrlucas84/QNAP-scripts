#!/opt/bin/bash
# script called by cron
# /share/CACHEDEV1_DATA/myprograms/logrotate/logrotate.sh

LOG=/share/CACHEDEV1_DATA/myprograms/logrotate/logrotate.log
#check if link /dev/fd exists
if [ ! -e /dev/fd ]
then
	/bin/echo "[$(/bin/date '+%F %T.%3N')] /dev/fd does NOT exist." >> $LOG
fi
timestamp_log() { while IFS='' read -r line; do /bin/echo "[$(/bin/date '+%F %T.%3N')] $line" >> "$1"; done; };
#exec 2>&1>>"$LOG"
exec 2>&1> >(timestamp_log $LOG)
/bin/echo "Starting logrotate.sh"
/opt/sbin/logrotate /share/CACHEDEV1_DATA/myprograms/logrotate/logrotate.conf
/bin/echo "End of logrotate.sh"
