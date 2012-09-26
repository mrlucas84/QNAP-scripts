#!/opt/bin/bash
# script called by cron
timestamp_log() { while IFS='' read -r line; do echo "[$(date '+%F %T')] $line" >> "$1"; done; };
LOG=/share/HDA_DATA/logrotate/logrotate.log
#exec 2>&1>>"$LOG"
exec 2>&1> >(timestamp_log $LOG)
echo "Starting logrotate.sh"
/opt/sbin/logrotate /share/HDA_DATA/logrotate/logrotate.conf
echo "End of logrotate.sh"
