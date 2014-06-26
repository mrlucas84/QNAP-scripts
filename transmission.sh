#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion
# /share/HDA_DATA/Transmission/transmission.sh
# transmission-daemon variables
trans_d=/opt/bin/transmission-daemon
#trans_home=/opt/etc/transmission
trans_usr=transmission
cfg_dir=/share/HDA_DATA/Transmission/.config
log_d=/share/HDA_DATA/Transmission/transmission-daemon.log

#log variables
log=/share/HDA_DATA/Transmission/transmission.log
namedpipe=transmission_sh_pipe
alias ts='/opt/bin/ts'
echo "*** Starting transmission.sh"  | ts "%F %H:%M:%.S" >> $log
if [ -p $namedpipe ]; then
	echo "Named pipe $namedpipe exists. Deleting." | ts "%F %H:%M:%.S" >> $log
	rm -f "$namedpipe"
fi
# create named pipe
/opt/bin/mkfifo $namedpipe
# Start ts writing to a logfile, but pulling its input from our named pipe.
ts "%F %H:%M:%.S" >> $log < $namedpipe &
# capture ts's process ID for the wait command.
ts_pid=$!
# redirect the rest of the stderr and stdout to our named pipe.
exec > $namedpipe 2>&1
echo "PID of ts: $ts_pid"

echo "Checking whether transmission-daemon is already running..."
#If transmission is running, close it so only one instance runs when testing script from terminal
if [ "$(pidof transmission-daemon)" ] 
	then 
		echo "transmission-daemon is running. Killing it before start." 
		killall transmission-daemon
	else
		echo "transmission-daemon is not running. Continue."
fi
echo "Starting Transmission Daemon... "

############################ OPCION 1: usr root y exportando variables entorno.
#export EVENT_NOEPOLL=0
#export trans_web_home=/share/HDA_DATA/.qpkg/Optware/share/transmission/web
#/share/HDA_DATA/.qpkg/Optware/bin/transmission-daemon --auth --username $remote_usr --password $remote_passwd --port $port --config-dir $cfg_dir --download-dir $torrent_dir -c $watch_dir

############################ OPCION 2: directa con usr transmission sin variables entorno
#/opt/bin/coreutils-su $trans_usr -c "EVENT_NOEPOLL=0 $trans_d --blocklist --auth --username $remote_usr --password $remote_passwd --config-dir $cfg_dir --download-dir $torrent_dir -c $watch_dir"
/opt/bin/coreutils-su $trans_usr -c "EVENT_NOEPOLL=0 $trans_d --config-dir $cfg_dir --logfile $log_d"

#Wait a while till the daemon has started...
sleep 20

#Set a few settings  REMOVED. ALL SET IN settings.json
#$/opt/bin/transmission-remote -n $remote_usr:$remote_passwd --portmap --port $trans_port --pex --encryption-preferred

echo "Transmission has started"
#Remove Transmission link just in case so it doesn't cause any trouble in the future.
trans_symlink=/etc/rcS.d/QS901transmission
if [ -f  $trans_symlink ]
	then
		echo "Link $trans_symlink exists. Removing."
		rm $trans_symlink
	else
		echo "Link $trans_symlink does not exist. Nothing to be done"
fi
# close the stderr and stdout file descriptors.
exec 1>&- 2>&-

# Wait for ts to finish since now that other end of the pipe has closed.
wait $ts_pid
#delete named pipe when finished
trap 'rm -f "$namedpipe"' EXIT
echo "*** End of transmission.sh" | ts "%F %H:%M:%.S" >> $log
