#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
# this is called by autorun.sh
# /share/HDA_DATA/.qpkg/autorun/autorunmaster.sh
#alias ts='/opt/bin/ts'
log=/share/HDA_DATA/.qpkg/autorun/autorunmaster.log
stdlog=/share/HDA_DATA/.qpkg/autorun/autorunmaster_std.log
echo "$(date '+%F %T') *** Starting autorunmaster.sh" >> $log
#namedpipe=/share/HDA_DATA/.qpkg/autorun/autorunmaster.sh.pipe
apache_conf=/etc/config/apache/apache.conf
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
echo "$(date '+%F %T') PATH=$PATH" >> $log

#Dani 12/11/2011 modificado segun http://forum.qnap.com/viewtopic.php?f=85&t=18977
#FIRST start Optware and delete the /etc/rcS.d/QS100...sh
echo "$(date '+%F %T') Starting Optware" >> $log
/etc/init.d/Optware.sh start >> $log
rm -f /etc/rcS.d/QS100Optware
echo "$(date '+%F %T') Optware started" >> $log
echo "$(date '+%F %T') Setting up custom scripts" >> $log
# Fin Dani 12/11/2011

#sobreescribir config SSH con la propia 
echo "$(date '+%F %T') Delete /etc/ssh/sshd_config and recreate as symlink to /share/HDA_DATA/ssh/sshd_config" >> $log
rm -f /etc/ssh/sshd_config
ln -s /share/HDA_DATA/ssh/sshd_config /etc/ssh/sshd_config

#sobreescribir configuracion apache
/bin/grep "apache-custom" $apache_conf >/dev/null
if [ $? = 0 ]
	then
		echo "$(date '+%F %T') $apache_conf does NOT contain customizations. Including now." >> $log
		echo "$(date '+%F %T') Include /share/HDA_DATA/apache/apache-custom.conf" >> $apache_conf
		echo "$(date '+%F %T') Restarting apache" >> $log
		/etc/init.d/Qthttpd.sh restart >> $log
	else
		echo "$(date '+%F %T') $apache_conf already contains customizations. Nothing to be done." >> $log
fi
#echo "Copying apache SSL custom conf" >> $log
#cp -f /share/HDA_DATA/apache/extra/apache-ssl.conf /etc/config/apache/extra/apache-ssl.conf

#echo "Restarting apache" >> $log
#/etc/init.d/Qthttpd.sh restart >> $log

# crea enlace a script de transmission para que se ejecute cuando toca.
#echo "Creating symlink /etc/rcS.d/QS901transmission -> /share/HDA_DATA/Transmission/transmission.sh"
#/bin/ln -sf /share/HDA_DATA/Transmission/transmission.sh /etc/rcS.d/QS901transmission

#Dani 12/11/2011
echo "$(date '+%F %T') Calling Transmission script /share/HDA_DATA/Transmission/transmission.sh"
/share/HDA_DATA/Transmission/transmission.sh
echo "$(date '+%F %T') Transmission script done." >> $log

echo "$(date '+%F %T') Copying /usr/local/etc/services to /etc/services" >> $log
cp -f /usr/local/etc/services /etc/services
sleep 2
export OPTWARE_TARGET=cs08q1armel
echo "$(date '+%F %T') Starting xinetd..." >> $log
if [ -e "/opt/sbin/xinetd" ]
	then
		/sbin/daemon_mgr xinetd start "/opt/sbin/xinetd"
		echo "$(date '+%F %T') xinetd started" >> $log
#		sleep 5
	else
		echo "$(date '+%F %T') xinetd not accessible" >> $log
fi
#echo "Closing output redirection to log file"
## close the stderr and stdout file descriptors.
#exec 1>&- 2>&-
#
## Wait for ts to finish since now that other end of the pipe has closed.
#wait $ts_pid
##delete named pipe when finished
#trap 'rm "$namedpipe"' EXIT
echo "$(date '+%F %T') *** End of autorunmaster.sh" >> $log
