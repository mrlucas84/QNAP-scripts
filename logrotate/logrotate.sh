#!/opt/bin/bash
# script called by cron
# /share/CACHEDEV1_DATA/myprograms/logrotate/logrotate.sh
timestamp_log() { while IFS='' read -r line; do echo "[$(date '+%F %T')] $line" >> "$1"; done; };
LOG=/share/CACHEDEV1_DATA/myprograms/logrotate/logrotate.log
#exec 2>&1>>"$LOG"
exec 2>&1> >(timestamp_log $LOG)
echo "Starting logrotate.sh"
/opt/sbin/logrotate /share/CACHEDEV1_DATA/myprograms/logrotate/logrotate.conf
echo "End of logrotate.sh"
