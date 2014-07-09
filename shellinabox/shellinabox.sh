#!/bin/sh
make_base(){
# Determine BASE installation location according to smb.conf
BASE_GROUP="/share/HDA_DATA /share/HDB_DATA /share/HDC_DATA /share/HDD_DATA /share/HDE_DATA /share/HDF_DATA /share/HDG_DATA /share/HDH_DATA /share/MD0_DATA /share/MD1_DATA /share/MD2_DATA /share/MD3_DATA"
publicdir=`/sbin/getcfg Public path -f /etc/config/smb.conf`
if [ ! -z $publicdir ] && [ -d $publicdir ];then
        publicdirp1=`/bin/echo $publicdir | /bin/cut -d "/" -f 2`
        publicdirp2=`/bin/echo $publicdir | /bin/cut -d "/" -f 3`
        publicdirp3=`/bin/echo $publicdir | /bin/cut -d "/" -f 4`
        if [ ! -z $publicdirp1 ] && [ ! -z $publicdirp2 ] && [ ! -z $publicdirp3 ]; then
                [ -d "/${publicdirp1}/${publicdirp2}/Public" ] && VOL_BASE="/${publicdirp1}/${publicdirp2}"
        fi
fi

# Determine BASE installation location by checking where the Public folder is.
if [ -z $VOL_BASE ]; then
        for datadirtest in $BASE_GROUP; do
                [ -d $datadirtest/Public ] && VOL_BASE="/${publicdirp1}/${publicdirp2}"
        done
fi
if [ -z $VOL_BASE ] ; then
        echo "The Public share not found."
        return 1
fi
}

#change_apache()
#{
#	/bin/grep -q cnx_user /etc/default_config/apache-sys-proxy-ssl.conf.tplt
#	if [ $? -eq 0 ] ; then
#		echo "cnx_user is already in base of ssl proxy"
#	else
#		NBL=`/bin/grep -n ProxyPass /etc/default_config/apache-sys-proxy-ssl.conf.tplt | /usr/bin/head -n 1 | /bin/cut -d: -f1`
#		sed -i "${NBL}i\ProxyPass /cnx_user http://127.0.0.1:4200/cnx_user" /etc/default_config/apache-sys-proxy-ssl.conf.tplt
#		/etc/init.d/stunnel.sh restart
#	fi
#}
#change_apache()
#{
#	/bin/grep -q cnx_user /etc/default_config/apache-sys-proxy.conf.tplt
#	if [ $? -eq 0 ] ; then
#		echo "cnx_user is already in base of http proxy"
#	else
#		echo "cnx_user is NOT in base of http proxy. Setting it up."
#		NBL=`/bin/grep -n ProxyPass /etc/default_config/apache-sys-proxy.conf.tplt | /usr/bin/head -n 1 | /bin/cut -d: -f1`
#		sed -i "${NBL}i\ProxyPass /cnx_user http://127.0.0.1:4200/cnx_user" /etc/default_config/apache-sys-proxy.conf.tplt
#		/etc/init.d/stunnel.sh restart
#	fi
#}
########### START of SHELL script
make_base
####
QPKG_DIR=${VOL_BASE}/.qpkg/shellinabox
###
########## TEST if firts start
if [ ! -e /root/.shellinabox_lock ] ; then
        if [ ! -e /myprog ] ; then
                mkdir /myprog
        fi
        ln -s ${QPKG_DIR} /myprog/shellinabox
	ln -s /myprog/shellinabox/shellinabox.sh /sbin/siab_mgr
	if [ ! -e /myprog/shellinabox/shellinabox.conf ] ; then
		cp /myprog/shellinabox/shellinabox.conf.ori /myprog/shellinabox/shellinabox.conf
	fi
	if [ ! -e /myprog/shellinabox/user.lst ] ; then
		cp /myprog/shellinabox/user.lst.ori /myprog/shellinabox/user.lst
	fi
	if [ -e /share/Web ] ; then
		rm -f /share/Web/cnx_user
		ln -s /myprog/shellinabox/www /share/Web/cnx_user
	else
		rm -f /share/Qweb/cnx_user
		ln -s /myprog/shellinabox/www /share/QWeb/cnx_user
	fi
#	change_apache
	touch /root/.shellinabox_lock
        /sbin/log_tool -t 0 -a "shellinabox environment is set"
fi

case "$1" in

start)
	REP=`/sbin/getcfg shellinabox Enable -u -d FALSE -f /etc/config/qpkg.conf`
        if [ "$REP" != "TRUE" ] ; then
                if [ "${2}" = "force" ] ; then
                        echo " OK Enable is FALSE but force action  ... it's your responsability !!!! "
                        shift
                else
                        echo "shellinabox is not Enable"
                        /sbin/log_tool -t 2 -a "shellinabox is Disable can't be started ... "
                        exit 1
                fi
        fi
### please test if ssl is configured ...
#	REP=`/sbin/getcfg Stunnel Enable -d 0`
#	if [ $REP -eq 0 ] ; then
#		/sbin/log_tool -t 2 -a "SSL is NOT enable for Web Admin ... shellinabox can't start"
#		exit 1
#	fi
###
#	PORT=`/sbin/getcfg Stunnel Port -d 443`
#	/sbin/setcfg shellinabox Web_Port $PORT -f /etc/config/qpkg.conf
	rm -f /tmp/shellinabox.log
#	/sbin/daemon_mgr shellinaboxd start "/myprog/shellinabox/bin/shellinaboxd -u guest -g guest --background=/tmp/shellinaboxd.pid -t --disable-ssl-menu --localhost-only -f favicon.ico:/myprog/shellinabox/favicon.ico -s /cnx_user:guest:guest:/tmp:/myprog/shellinabox/cnx_user.sh 1>/dev/null 2>/tmp/shellinabox.log &"

#PRUEBA /usr/bin/shellinaboxd -q --background=/var/run/shellinaboxd.pid -c /var/lib/shellinabox -p 4200 -u shellinabox -g shellinabox --user-css Black on White:+/etc/shellinabox/options-enabled/00+Black on White.css,White On Black:-/etc/shellinabox/options-enabled/00_White On Black.css;Color Terminal:+/etc/shellinabox/options-enabled/01+ColorTerminal.css,Monochrome:-/etc/shellinabox/options-enabled/01_Monochrome.css -s/:LOGIN -t --no-beep
	/sbin/daemon_mgr shellinaboxd start "/myprog/shellinabox/bin/shellinaboxd -u guest -g guest --background=/tmp/shellinaboxd.pid --localhost-only --disable-ssl -f favicon.ico:/myprog/shellinabox/terminal.ico --css=/share/HDA_DATA/shellinabox/share/doc/shellinabox/white-on-black.css -s /cnx_user:guest:guest:/tmp:/myprog/shellinabox/cnx_user.sh 1>/dev/null 2>/tmp/shellinabox.log &"
	/sbin/log_tool -t 0 -a "shellinabox server is started "
;;

stop)
	/sbin/daemon_mgr shellinaboxd stop "kill -9 `cat /tmp/shellinaboxd.pid`"
	/bin/rm -f /tmp/shellinaboxd.pid
	/sbin/log_tool -t 0 -a "shellinabox server is stoped"
;;

restart)
	$0 stop
	sleep 2
	$0 start
;;
set_all)
	/sbin/setcfg SIAB Auth_user "ALL" -f /myprog/shellinabox/shellinabox.conf
;;
set_list)
	/sbin/setcfg SIAB Auth_user "LIST" -f /myprog/shellinabox/shellinabox.conf
;;
set_admin)
	/sbin/setcfg SIAB Auth_user "ADMIN" -f /myprog/shellinabox/shellinabox.conf
;;
status)
	REP=`/sbin/getcfg shellinabox Enable -u -d FALSE -f /etc/config/qpkg.conf`
        if [ "$REP" != "TRUE" ] ; then
		echo " SIAB is Disable"
	else
		echo " SIAB is Enable"
		REP=`/sbin/getcfg SIAB Auth_user -d "INVALID_VALUE" -f /myprog/shellinabox/shellinabox.conf`
		echo " SIAB Authorised user is : $REP "
		PORT=`/sbin/getcfg Stunnel Port -d 443`
		echo " SIAB https port (ONLY) : $PORT "
		echo " SIAB tasks running (guest) (minimum 2 tasks) "
		ps -eaf | grep -v grep | grep shellinaboxd
		if [ -e /tmp/shellinaboxd.pid ] ; then
			PID=`cat /tmp/shellinaboxd.pid`
			echo " SIAB PID of first task : $PID "
		fi
	fi
;;
log)
	echo " SIAB log (generally empty ... )"
	cat /tmp/shellinabox.log
	echo " SIAB end of log"
;;
qpkg_enable)
	/sbin/setcfg shellinabox Enable "TRUE" -f /etc/config/qpkg.conf
;;
qpkg_disable)
	/sbin/setcfg shellinabox Enable "FALSE" -f /etc/config/qpkg.conf
;;
*)
	echo "Usage is :"
	echo " $0 start|stop|restart|start force "
	echo " $0 set_admin|set_all|set_list (set user authorization)"
	echo " $0 log (print log if needed ... generally empty)"
	echo " $0 status "
	echo " $0 qpkg_anable|qpkg_disable "
;;

esac

