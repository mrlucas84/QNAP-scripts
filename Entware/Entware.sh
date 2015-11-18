#!/bin/sh

RETVAL=0
QPKG_NAME="Entware-ng"

_exit()
{
    /bin/echo -e "Error: $*"
    /bin/echo
    exit 1
}

QPKG_DIR=$(/sbin/getcfg Entware-ng Install_Path -f /etc/config/qpkg.conf)

case "$1" in
  start)
  if [ `/sbin/getcfg ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf` = UNKNOWN ]; then
  	/sbin/setcfg ${QPKG_NAME} Enable TRUE -f /etc/config/qpkg.conf
  elif [ `/sbin/getcfg ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf` != TRUE ]; then
  	_exit  "${QPKG_NAME} is disabled."
  fi

  /bin/echo "Enable Entware-ng/opkg"
	# sym-link $QPKG_DIR to /opt
	/bin/rm -rf /opt
	/bin/ln -sf $QPKG_DIR /opt
	# adding opkg apps into system path ...


	/bin/cat /root/.profile | /bin/grep "source" 1>>/dev/null 2>>/dev/null
	[ $? -ne 0 ] && /bin/echo "source /opt/etc/profile" >> /root/.profile
	# startup Entware-ng services
	/opt/etc/init.d/rc.unslung start
    ;;
  stop)
  	/bin/echo "Disable Entware-ng/opkg"
	/opt/etc/init.d/rc.unslung stop
	/bin/sed -i '/source \/opt\/etc\/profile/d' /root/.profile
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

