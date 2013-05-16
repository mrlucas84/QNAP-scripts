#!/bin/sh

RETVAL=0
QPKG_NAME="Optware"

_exit()
{
    /bin/echo -e "Error: $*"
    /bin/echo
    exit 1
}

# Determine BASE installation location according to smb.conf
BASE=
publicdir=`/sbin/getcfg Public path -f /etc/config/smb.conf`
if [ ! -z $publicdir ] && [ -d $publicdir ];then
	publicdirp1=`/bin/echo $publicdir | /bin/cut -d "/" -f 2`
	publicdirp2=`/bin/echo $publicdir | /bin/cut -d "/" -f 3`
	publicdirp3=`/bin/echo $publicdir | /bin/cut -d "/" -f 4`
	if [ ! -z $publicdirp1 ] && [ ! -z $publicdirp2 ] && [ ! -z $publicdirp3 ]; then
		[ -d "/${publicdirp1}/${publicdirp2}/Public" ] && BASE="/${publicdirp1}/${publicdirp2}"
	fi
fi

# Determine BASE installation location by checking where the Public folder is.
if [ -z $BASE ]; then
	for datadirtest in /share/HDA_DATA /share/HDB_DATA /share/HDC_DATA /share/HDD_DATA /share/MD0_DATA; do
		[ -d $datadirtest/Public ] && BASE="/${publicdirp1}/${publicdirp2}"
	done
fi
if [ -z $BASE ] ; then
	echo "The Public share not found."
	_exit 1
fi
QPKG_DIR=${BASE}/.qpkg/Optware

case "$1" in
  start)
  if [ `/sbin/getcfg ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf` = UNKNOWN ]; then
  	/sbin/setcfg ${QPKG_NAME} Enable TRUE -f /etc/config/qpkg.conf
  elif [ `/sbin/getcfg ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf` != TRUE ]; then
  	_exit  "${QPKG_NAME} is disabled."
  fi

  /bin/echo "Enable Optware/ipkg"
	# sym-link $QPKG_DIR to /opt
	/bin/rm -rf /opt
	/bin/ln -sf $QPKG_DIR /opt
 	
	# adding Ipkg apps into system path ...
	/bin/cat /etc/profile | /bin/grep "PATH" | /bin/grep "/opt/bin" 1>>/dev/null 2>>/dev/null
	#Dani 12/11/2011
	# Bug fix for following: put IPKG first, per http://forum.qnap.com/viewtopic.php?f=124&t=15663
	# was [ $? -ne 0 ] && /bin/echo "export PATH=$PATH":/opt/bin:/opt/sbin >> /etc/profile
	[ $? -ne 0 ] && /bin/echo "export PATH=/opt/bin:/opt/sbin:\$PATH" >> /etc/profile
	 
	;;
  stop)
  /bin/echo "Disable Optware/ipkg"
	export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
	
	/bin/sync
	/bin/sleep 1
	;;
  restart)
	$0 stop
	$0 start
	;;
  *)
	echo "Usage: $0 {start|stop|restart}"
	exit 1
esac

exit $RETVAL

