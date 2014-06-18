#!/bin/sh
# con /opt/bin/bash parece que no se lanza
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
# this is called by autorun.sh
# /share/HDA_DATA/.qpkg/autorun/autorunmaster.sh

alias ts='/opt/bin/ts'
AUTORUNLOG=/share/HDA_DATA/.qpkg/autorun/autorunmaster.log
PIPEFILE=test2pipe
# create named pipe
mkfifo $PIPEFILE
# Start tee writing to a logfile, but pulling its input from our named pipe.
ts "%F %H:%M:%.S" >> $AUTORUNLOG < $PIPEFILE &
# capture tee's process ID for the wait command.
TEEPID=$!
# redirect the rest of the stderr and stdout to our named pipe.
exec > $PIPEFILE 2>&1

echo ">>> Starting autorunmaster.sh"
# adding IPKG apps into system path ... 
# Dani 12/11/2011 ESTO SE HACE EN /opt/Optware.sh 
#/bin/cat /etc/profile | /bin/grep "PATH" | /bin/grep "/opt/bin" 1>>/dev/null 2>>/dev/null
# Bug fix for following: put IPKG first, per http://forum.qnap.com/viewtopic.php?f=124&t=15663
# was [ $? -ne 0 ] && /bin/echo "export PATH=$PATH":/opt/bin:/opt/sbin >> /etc/profile
#[ $? -ne 0 ] && /bin/echo "export PATH=/opt/bin:/opt/sbin:\$PATH" >> /etc/profile
echo "Value of env variable PATH=$PATH"

#Dani 12/11/2011 modificado segun http://forum.qnap.com/viewtopic.php?f=85&t=18977
#FIRST start Optware and delete the /etc/rcS.d/QS100...sh
echo "Starting Optware"
/etc/init.d/Optware.sh start
rm -f /etc/rcS.d/QS100Optware
echo "Optware started"
echo "Setting up custom scripts"
# Fin Dani 12/11/2011

#sobreescribir config SSH con la propia 
echo "Overriding /etc/ssh/sshd_config, linking to /share/HDA_DATA/ssh/sshd_config"
rm /etc/ssh/sshd_config
ln -s /share/HDA_DATA/ssh/sshd_config /etc/ssh/sshd_config

# crea enlace a script de transmission para que se ejecute cuando toca.
#echo "Creating symlink /etc/rcS.d/QS901transmission -> /share/HDA_DATA/Transmission/transmission.sh"
#/bin/ln -sf /share/HDA_DATA/Transmission/transmission.sh /etc/rcS.d/QS901transmission

#Dani 12/11/2011
echo "Calling Transmission script /share/HDA_DATA/Transmission/transmission.sh"
/share/HDA_DATA/Transmission/transmission.sh
echo "Transmission script done."

echo "Copying /usr/local/etc/services to /etc/services"
cp /usr/local/etc/services /etc/services
sleep 2
export OPTWARE_TARGET=cs08q1armel
echo "xinetd start"
if [ -e "/opt/sbin/xinetd" ]
	then
		/sbin/daemon_mgr xinetd start "/opt/sbin/xinetd" 2>/dev/null
		echo "xinetd started"
#		sleep 5
	else
		echo "xinetd not accessible"
fi
echo "<<< End of autorunmaster.sh"

# close the stderr and stdout file descriptors.
exec 1>&- 2>&-

# Wait for tee to finish since now that other end of the pipe has closed.
wait $TEEPID
#delete named pipe when finished
trap 'rm "$PIPEFILE"' EXIT
