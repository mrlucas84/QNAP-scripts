#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
# this is called by autorun.sh
# /share/HDA_DATA/.qpkg/autorun/autorunmaster.sh
log=/share/HDA_DATA/.qpkg/autorun/autorunmaster.log
namedpipe=autorunmaster_sh_pipe
alias ts='/opt/bin/ts'
echo "*** Starting autorunmaster.sh" | ts "%F %H:%M:%.S" >> $log
if [ -p $namedpipe ]; then
	echo "Named pipe $namedpipe exists. Deleting." | ts "%F %H:%M:%.S" >> $log
	rm -f "$namedpipe"
fi
# create named pipe
mkfifo $namedpipe
# Start ts writing to a logfile, but pulling its input from our named pipe.
ts "%F %H:%M:%.S" >> $log < $namedpipe &
# capture ts's process ID for the wait command.
ts_pid=$!
# redirect the rest of the stderr and stdout to our named pipe.
exec > $namedpipe 2>&1

echo "PID of ts: $ts_pid"
# adding IPKG apps into system path ... 
# Dani 12/11/2011 ESTO SE HACE EN /opt/Optware.sh 
#/bin/cat /etc/profile | /bin/grep "PATH" | /bin/grep "/opt/bin" 1>>/dev/null 2>>/dev/null
# Bug fix for following: put IPKG first, per http://forum.qnap.com/viewtopic.php?f=124&t=15663
# was [ $? -ne 0 ] && /bin/echo "export PATH=$PATH":/opt/bin:/opt/sbin >> /etc/profile
#[ $? -ne 0 ] && /bin/echo "export PATH=/opt/bin:/opt/sbin:\$PATH" >> /etc/profile
echo "PATH=$PATH"

#Dani 12/11/2011 modificado segun http://forum.qnap.com/viewtopic.php?f=85&t=18977
#FIRST start Optware and delete the /etc/rcS.d/QS100...sh
echo "Starting Optware"
/etc/init.d/Optware.sh start
rm -f /etc/rcS.d/QS100Optware
echo "Optware started"
echo "Setting up custom scripts"
# Fin Dani 12/11/2011

#sobreescribir config SSH con la propia 
echo "Delete /etc/ssh/sshd_config and recreate as symlink to /share/HDA_DATA/ssh/sshd_config"
rm -f /etc/ssh/sshd_config
ln -s /share/HDA_DATA/ssh/sshd_config /etc/ssh/sshd_config

# crea enlace a script de transmission para que se ejecute cuando toca.
#echo "Creating symlink /etc/rcS.d/QS901transmission -> /share/HDA_DATA/Transmission/transmission.sh"
#/bin/ln -sf /share/HDA_DATA/Transmission/transmission.sh /etc/rcS.d/QS901transmission

#Dani 12/11/2011
echo "Calling Transmission script /share/HDA_DATA/Transmission/transmission.sh"
/share/HDA_DATA/Transmission/transmission.sh
echo "Transmission script done."

echo "Copying /usr/local/etc/services to /etc/services"
cp -f /usr/local/etc/services /etc/services
sleep 2
export OPTWARE_TARGET=cs08q1armel
echo "xinetd start"
if [ -e "/opt/sbin/xinetd" ]
	then
		/sbin/daemon_mgr xinetd start "/opt/sbin/xinetd"
		echo "xinetd started"
#		sleep 5
	else
		echo "xinetd not accessible"
fi
echo "Closing output redirection to log file"
# close the stderr and stdout file descriptors.
exec 1>&- 2>&-

# Wait for ts to finish since now that other end of the pipe has closed.
wait $ts_pid
#delete named pipe when finished
trap 'rm "$namedpipe"' EXIT
echo "*** End of autorunmaster.sh" | ts "%F %H:%M:%.S" >> $log
