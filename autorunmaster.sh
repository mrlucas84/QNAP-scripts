#!/bin/sh
#this is called by autorun.sh
timestamp_log() { while IFS='' read -r line; do echo "[$(date '+%F %T')] $line" >> "$1"; done; };
AUTORUNLOG=/share/HDA_DATA/.qpkg/autorun/autorunmaster.log
#exec &>"$AUTORUNLOG"
#exec 2>&1>>$AUTORUNLOG
exec 2>&1> >(timestamp_log $AUTORUNLOG)
echo "Starting autorunmaster.sh"
# adding Ipkg apps into system path ... 
# Dani 12/11/2011 ESTO SE HACE EN /opt/etc/init.d/Optware.sh 
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

echo "Starting KMS server vlmcsd '/share/HDA_DATA/kms-vlmcsd/vlmcsd.sh forcestart'"
/share/HDA_DATA/kms-vlmcsd/vlmcsd.sh forcestart

echo "End of autorunmaster.sh"
