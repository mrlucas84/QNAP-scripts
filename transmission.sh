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

log=/share/HDA_DATA/Transmission/transmission.log

log(){
	/bin/echo "$(/bin/date '+%F %T.%3N') $1" >> $log
}

log "***** Starting transmission.sh *****"
# redirect the rest of the stderr and stdout to log.
exec > $log 2>&1

#If transmission is running, close it so only one instance runs when testing script from terminal
if [ "$(pidof transmission-daemon)" ] 
	then 
		log "transmission-daemon is running. Killing it before start." 
		killall transmission-daemon
	else
		log "transmission-daemon is not running. Continue."
fi
log "Starting transmission-daemon ..."

############################ OPCION 1: usr root y exportando variables entorno.
#export EVENT_NOEPOLL=0
#export trans_web_home=/share/HDA_DATA/.qpkg/Optware/share/transmission/web
#/share/HDA_DATA/.qpkg/Optware/bin/transmission-daemon --auth --username $remote_usr --password $remote_passwd --port $port --config-dir $cfg_dir --download-dir $torrent_dir -c $watch_dir

############################ OPCION 2: directa con usr transmission sin variables entorno
#/opt/bin/coreutils-su $trans_usr -c "EVENT_NOEPOLL=0 $trans_d --blocklist --auth --username $remote_usr --password $remote_passwd --config-dir $cfg_dir --download-dir $torrent_dir -c $watch_dir"
/opt/bin/coreutils-su $trans_usr -c "EVENT_NOEPOLL=0 $trans_d --config-dir $cfg_dir --logfile $log_d"

#Wait a while till the daemon has started...
/bin/sleep 20

#Set a few settings  REMOVED. ALL SET IN settings.json
#$/opt/bin/transmission-remote -n $remote_usr:$remote_passwd --portmap --port $trans_port --pex --encryption-preferred

log "Transmission has started"
#Remove Transmission link just in case so it doesn't cause any trouble in the future.
trans_symlink=/etc/rcS.d/QS901transmission
if [ -f  $trans_symlink ]
	then
		log "Link $trans_symlink exists. Removing."
		/bin/rm -f $trans_symlink
	else
		log "Link $trans_symlink does not exist. Nothing to be done"
fi
log "***** End of transmission.sh *****"
