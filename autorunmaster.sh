#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
# this is called by autorun.sh
# /share/HDA_DATA/.qpkg/autorun/autorunmaster.sh
log=/share/HDA_DATA/.qpkg/autorun/autorunmaster.log
stdlog=/share/HDA_DATA/.qpkg/autorun/autorunmaster_std.log
echo "*** Starting autorunmaster.sh" | ts "%F %H:%M:%.S" >> $log
#namedpipe=/share/HDA_DATA/.qpkg/autorun/autorunmaster.sh.pipe
apache_conf=/etc/config/apache/apache.conf
#alias ts='/opt/bin/ts'
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
exec > $stdlog 2>&1
#echo "*** Starting autorunmaster.sh"

#echo "PID of ts: $ts_pid"
# adding IPKG apps into system path ... 
# Dani 12/11/2011 ESTO SE HACE EN /opt/Optware.sh 
#/bin/cat /etc/profile | /bin/grep "PATH" | /bin/grep "/opt/bin" 1>>/dev/null 2>>/dev/null
# Bug fix for following: put IPKG first, per http://forum.qnap.com/viewtopic.php?f=124&t=15663
# was [ $? -ne 0 ] && /bin/echo "export PATH=$PATH":/opt/bin:/opt/sbin >> /etc/profile
#[ $? -ne 0 ] && /bin/echo "export PATH=/opt/bin:/opt/sbin:\$PATH" >> /etc/profile
echo "PATH=$PATH" | ts "%F %H:%M:%.S" >> $log

#Dani 12/11/2011 modificado segun http://forum.qnap.com/viewtopic.php?f=85&t=18977
#FIRST start Optware and delete the /etc/rcS.d/QS100...sh
echo "Starting Optware" | ts "%F %H:%M:%.S" >> $log
/etc/init.d/Optware.sh start | ts "%F %H:%M:%.S" >> $log
rm -f /etc/rcS.d/QS100Optware
echo "Optware started" | ts "%F %H:%M:%.S" >> $log
echo "Setting up custom scripts" | ts "%F %H:%M:%.S" >> $log
# Fin Dani 12/11/2011

#sobreescribir config SSH con la propia 
echo "Delete /etc/ssh/sshd_config and recreate as symlink to /share/HDA_DATA/ssh/sshd_config" | ts "%F %H:%M:%.S" >> $log
rm -f /etc/ssh/sshd_config
ln -s /share/HDA_DATA/ssh/sshd_config /etc/ssh/sshd_config

#sobreescribir configuracion apache
/bin/grep "apache-custom" $apache_conf >/dev/null
if [ $? = 0 ]
	then
		echo "$apache_conf does NOT contain customizations. Including now." | ts "%F %H:%M:%.S" >> $log
		echo "Include /share/HDA_DATA/apache/apache-custom.conf" >> $apache_conf
		echo "Restarting apache" | ts "%F %H:%M:%.S" >> $log
		/etc/init.d/Qthttpd.sh restart | ts "%F %H:%M:%.S" >> $log
	else
		echo "$apache_conf already contains customizations. Nothing to be done." | ts "%F %H:%M:%.S" >> $log
fi
#echo "Copying apache SSL custom conf" | ts "%F %H:%M:%.S" >> $log
#cp -f /share/HDA_DATA/apache/extra/apache-ssl.conf /etc/config/apache/extra/apache-ssl.conf

#echo "Restarting apache" | ts "%F %H:%M:%.S" >> $log
#/etc/init.d/Qthttpd.sh restart | ts "%F %H:%M:%.S" >> $log

# crea enlace a script de transmission para que se ejecute cuando toca.
#echo "Creating symlink /etc/rcS.d/QS901transmission -> /share/HDA_DATA/Transmission/transmission.sh"
#/bin/ln -sf /share/HDA_DATA/Transmission/transmission.sh /etc/rcS.d/QS901transmission

#Dani 12/11/2011
echo "Calling Transmission script /share/HDA_DATA/Transmission/transmission.sh"
/share/HDA_DATA/Transmission/transmission.sh
echo "Transmission script done." | ts "%F %H:%M:%.S" >> $log

echo "Copying /usr/local/etc/services to /etc/services" | ts "%F %H:%M:%.S" >> $log
cp -f /usr/local/etc/services /etc/services
sleep 2
export OPTWARE_TARGET=cs08q1armel
echo "Starting xinetd..." | ts "%F %H:%M:%.S" >> $log
if [ -e "/opt/sbin/xinetd" ]
	then
		/sbin/daemon_mgr xinetd start "/opt/sbin/xinetd"
		echo "xinetd started" | ts "%F %H:%M:%.S" >> $log
#		sleep 5
	else
		echo "xinetd not accessible" | ts "%F %H:%M:%.S" >> $log
fi
#echo "Closing output redirection to log file"
## close the stderr and stdout file descriptors.
#exec 1>&- 2>&-
#
## Wait for ts to finish since now that other end of the pipe has closed.
#wait $ts_pid
##delete named pipe when finished
#trap 'rm "$namedpipe"' EXIT
echo "*** End of autorunmaster.sh" | ts "%F %H:%M:%.S" >> $log
