#!/opt/bin/bash
# script called by cron
# /share/CACHEDEV1_DATA/myprograms/logrotate/logrotate.sh

#check if link /dev/fd exists, if not, create it
if [ ! -e "$file" ]
then
	echo "/dev/fd does NOT exist. Creating link to /proc/self/fd"
	ln -s /proc/self/fd /dev/fd
fi
timestamp_log() { while IFS='' read -r line; do echo "[$(date '+%F %T')] $line" >> "$1"; done; };
LOG=/share/CACHEDEV1_DATA/myprograms/logrotate/logrotate.log
#exec 2>&1>>"$LOG"
exec 2>&1> >(timestamp_log $LOG)
echo "Starting logrotate.sh"
/opt/sbin/logrotate /share/CACHEDEV1_DATA/myprograms/logrotate/logrotate.conf
echo "End of logrotate.sh"
