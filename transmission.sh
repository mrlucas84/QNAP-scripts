#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion
# /share/HDA_DATA/Transmission/transmission.sh
alias ts='/opt/bin/ts'
LOG=/share/HDA_DATA/Transmission/transmission.log
PIPEFILE=test2pipe
# create named pipe
mkfifo $PIPEFILE
# Start tee writing to a logfile, but pulling its input from our named pipe.
ts "%F %H:%M:%.S" >> $LOG < $PIPEFILE &
# capture ts's process ID for the wait command.
TS_PID=$!
# redirect the rest of the stderr and stdout to our named pipe.
exec > $PIPEFILE 2>&1

echo "*** Starting transmission.sh"
echo "Checking whether transmission-daemon is already running..."
#Checks if transmission runs and closes it if it does. This is so I don't get more than one copy of Transmission at a time, when I test this file through Putty.
if [ "$(pidof transmission-daemon)" ] 
	then 
		echo "Transmission is running. Killing transmission-daemon before start." 
		killall transmission-daemon
	else
		echo "Transmission is not running. Continue."
fi
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
#Remove Transmission link just in case so it doesn't cause any trouble in the future.
TRANS_LINK=/etc/rcS.d/QS901transmission
[ -f  $TRANS_LINK ] && echo "Link $TRANS_LINK exists. Removing." && rm $TRANS_LINK || echo "Link $TRANS_LINK does not exist. Nothing to be done"
echo "*** End of transmission.sh"
# close the stderr and stdout file descriptors.
exec 1>&- 2>&-

# Wait for ts to finish since now that other end of the pipe has closed.
wait $TS_PID
#delete named pipe when finished
trap 'rm "$PIPEFILE"' EXIT
