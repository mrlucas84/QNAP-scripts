#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
# this is called by autorun.sh
# /share/HDA_DATA/.qpkg/autorun/autorunmaster.sh
#alias ts='/opt/bin/ts'
log=/share/HDA_DATA/.qpkg/autorun/autorunmaster.log
#stdlog=/share/HDA_DATA/.qpkg/autorun/autorunmaster_std.log
log(){
	/bin/echo "$(/bin/date '+%F %T.%3N') $1" >> $log
}
log "***** Starting autorunmaster.sh *****"
#namedpipe=/share/HDA_DATA/.qpkg/autorun/autorunmaster.sh.pipe
apache_conf=/etc/config/apache/apache.conf
apache_custom_conf=/share/HDA_DATA/apache/apache-custom.conf
#if [ -p $namedpipe ]; then
#	rm -f "$namedpipe"
#fi
## create named pipe
#mkfifo $namedpipe
## Start ts writing to a logfile, but pulling its input from our named pipe.
#ts "%F %H:%M:%.S" >> $log < $namedpipe &
## capture ts's process ID for the wait command.
#ts_pid=$!
## redirect the rest of the stderr and stdout to our named pipe.
#exec > $namedpipe 2>&1
exec > $log 2>&1
#echo "*** Starting autorunmaster.sh"

#echo "PID of ts: $ts_pid"
# adding IPKG apps into system path ... 
# Dani 12/11/2011 ESTO SE HACE EN /opt/Optware.sh 
#/bin/cat /etc/profile | /bin/grep "PATH" | /bin/grep "/opt/bin" 1>>/dev/null 2>>/dev/null
# Bug fix for following: put IPKG first, per http://forum.qnap.com/viewtopic.php?f=124&t=15663
# was [ $? -ne 0 ] && /bin/echo "export PATH=$PATH":/opt/bin:/opt/sbin >> /etc/profile
#[ $? -ne 0 ] && /bin/echo "export PATH=/opt/bin:/opt/sbin:\$PATH" >> /etc/profile
log "PATH=$PATH"

#Dani 12/11/2011 modificado segun http://forum.qnap.com/viewtopic.php?f=85&t=18977
#FIRST start Optware and delete the /etc/rcS.d/QS100...sh
log "Starting Optware"
/etc/init.d/Optware.sh start
/bin/rm -f /etc/rcS.d/QS100Optware
log "Optware started"
log "Setting up custom scripts"
# Fin Dani 12/11/2011

#sobreescribir config SSH con la propia 
log "Delete /etc/ssh/sshd_config and recreate as symlink to /share/HDA_DATA/ssh/sshd_config"
/bin/rm -f /etc/ssh/sshd_config
ln -s /share/HDA_DATA/ssh/sshd_config /etc/ssh/sshd_config

#modificar configuracion apache. quiet grep search
/bin/grep -q $apache_custom_conf $apache_conf
if [ $? -eq 0 ]
	then
		log "$apache_conf already includes $apache_custom_conf. Nothing to be done."
	else
		log "$apache_conf does NOT include $apache_custom_conf. Including now."
		/bin/echo "Include $apache_custom_conf" >> $apache_conf
		log "Restarting apache"
		/etc/init.d/Qthttpd.sh restart
fi
#echo "Copying apache SSL custom conf" >> $log
#cp -f /share/HDA_DATA/apache/extra/apache-ssl.conf /etc/config/apache/extra/apache-ssl.conf

#echo "Restarting apache" >> $log
#/etc/init.d/Qthttpd.sh restart >> $log

# crea enlace a script de transmission para que se ejecute cuando toca.
#echo "Creating symlink /etc/rcS.d/QS901transmission -> /share/HDA_DATA/Transmission/transmission.sh"
#/bin/ln -sf /share/HDA_DATA/Transmission/transmission.sh /etc/rcS.d/QS901transmission

#Dani 12/11/2011
log "Calling Transmission script /share/HDA_DATA/Transmission/transmission.sh"
/share/HDA_DATA/Transmission/transmission.sh
log "Transmission script done."

log "Copying /usr/local/etc/services to /etc/services"
/bin/cp -f /usr/local/etc/services /etc/services
/bin/sleep 2
export OPTWARE_TARGET=cs08q1armel
log "Starting xinetd..."
if [ -e "/opt/sbin/xinetd" ]
	then
		/sbin/daemon_mgr xinetd start "/opt/sbin/xinetd"
		log "xinetd started"
#		sleep 5
	else
		log "xinetd not accessible"
fi
#echo "Closing output redirection to log file"
## close the stderr and stdout file descriptors.
#exec 1>&- 2>&-
#
## Wait for ts to finish since now that other end of the pipe has closed.
#wait $ts_pid
##delete named pipe when finished
#trap 'rm "$namedpipe"' EXIT
log "***** End of autorunmaster.sh *****"
/bin/sync
/bin/sleep 1
