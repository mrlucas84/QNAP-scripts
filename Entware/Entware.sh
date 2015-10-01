#!/bin/sh

RETVAL=0
QPKG_NAME="Entware"

_exit()
{
    /bin/echo -e "Error: $*"
    /bin/echo
    exit 1
}

QPKG_DIR=$(/sbin/getcfg Entware Install_Path -f /etc/config/qpkg.conf)

case "$1" in
  start)
  if [ `/sbin/getcfg ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf` = UNKNOWN ]; then
  	/sbin/setcfg ${QPKG_NAME} Enable TRUE -f /etc/config/qpkg.conf
  elif [ `/sbin/getcfg ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf` != TRUE ]; then
  	_exit  "${QPKG_NAME} is disabled."
  fi

  /bin/echo "Enable Entware/opkg"
	# sym-link $QPKG_DIR to /opt
	/bin/rm -rf /opt
	/bin/ln -sf $QPKG_DIR /opt
	# adding opkg apps into system path ...
	/bin/cat /etc/profile | /bin/grep "PATH" | /bin/grep "/opt/bin" 1>>/dev/null 2>>/dev/null
	if [ $? -ne 0 ]; then
		#Dani 01/10/2015
		# Bug fix for following: put OPKG first, per http://forum.qnap.com/viewtopic.php?f=124&t=15663
		# was /bin/echo "export PATH=\$PATH:/opt/bin:/opt/sbin" >> /etc/profile
		/bin/echo "export PATH=/opt/bin:/opt/sbin:\$PATH" >> /etc/profile
		/bin/echo "export TERMINFO=/opt/share/terminfo" >> /etc/profile
		/bin/echo "export TERM=xterm-color">> /etc/profile
		/bin/echo "export TMP=/opt/tmp" >> /etc/profile
		/bin/echo "export TEMP=/opt/tmp" >> /etc/profile
	fi
	# startup Entware services
	/opt/etc/init.d/rc.unslung start
    ;;
  stop)
  	/bin/echo "Disable Entware/opkg"
	/opt/etc/init.d/rc.unslung stop
	
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

