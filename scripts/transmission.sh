#!/bin/sh
LOG=/share/HDA_DATA/Transmission/transmission.log
timestamp_log() { while IFS='' read -r line; do echo "[$(date '+%F %T')] $line" >> "$1"; done; };
#exec &> "$LOG"
#exec 2>&1>>"$LOG"
exec 2>&1> >(timestamp_log $LOG)

echo "Starting transmission.sh" 
#Checks if transmission runs and closes it if it does. This is so I don't get more than one copy of Transmission at a time, when I test this file through Putty.
[ "$(pidof transmission-daemon)" ] && echo "Transmission is running. Killing Transmission-daemon before restart." && killall transmission-daemon || echo "Transmission is not running."
TRANSMISSION_BIN=/opt/bin
#TRANSMISSION_HOME=/opt/etc/transmission
TRANSMISSION_USER=transmission
CONFIGFOLDER=/share/HDA_DATA/Transmission/.config
DAEMONLOG=/share/HDA_DATA/Transmission/transmission-daemon.log
echo "Starting Transmission Daemon... "

############################ OPCION 1: usr root y exportando variables entorno.
#export EVENT_NOEPOLL=0
#export TRANSMISSION_WEB_HOME=/share/HDA_DATA/.qpkg/Optware/share/transmission/web
#/share/HDA_DATA/.qpkg/Optware/bin/transmission-daemon --auth --username $REMOTE_USER --password $REMOTE_PASS --port $PORT --config-dir $CONFIGFOLDER --download-dir $TORRENTFOLDER -c $WATCHFOLDER

############################ OPCION 2: directa con usr transmission sin variables entorno
#/opt/bin/coreutils-su $TRANSMISSION_USER -c "EVENT_NOEPOLL=0 $TRANSMISSION_BIN/transmission-daemon --blocklist --auth --username $REMOTE_USER --password $REMOTE_PASS --config-dir $CONFIGFOLDER --download-dir $TORRENTFOLDER -c $WATCHFOLDER"
/opt/bin/coreutils-su $TRANSMISSION_USER -c "EVENT_NOEPOLL=0 $TRANSMISSION_BIN/transmission-daemon  --config-dir $CONFIGFOLDER --logfile $DAEMONLOG"

#Wait a while till the daemon has started...
sleep 20

#Set a few settings  REMOVED. ALL SET IN settings.json
#$TRANSMISSION_BIN/transmission-remote -n $REMOTE_USER:$REMOTE_PASS --portmap --port $TRANSMISSION_PORT --pex --encryption-preferred

echo "Transmission has started"
#Remove Transmission shortcut just in case so it doesn't cause any trouble in the future.
[ -f /etc/rcS.d/QS901transmission ] && echo "Shortcut exists. Removing." && rm /etc/rcS.d/QS901transmission || echo "Shortcut does not exist."
echo "End of transmission.sh"
