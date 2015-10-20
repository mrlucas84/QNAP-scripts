#!/bin/sh
trap '{ echo "Hey, you pressed Ctrl-C.  Time to quit." ; exit 1; }' INT
echo -n "Enter your name (in next 10 seconds) and press [ENTER]: "
read -t 10 var_name
if [ -z $var_name ] ; then
	exit 1
fi
ADM_ONLY=`/sbin/getcfg SIAB Auth_user -d "ADMIN" -u -f /share/CACHEDEV1_DATA/myprograms/shellinabox/shellinabox.conf`
case "$ADM_ONLY" in
	ADMIN)
        if [ "$var_name" != "admin" ] ; then
                echo "Hum! only administrator user is authorize ... exit"
                exit 1
        fi
	;;
	ALL)
        /bin/grep -q $var_name /etc/passwd
        if [ $? -ne 0 ] ; then
                echo "Hum! unknown name .... exit"
                exit 1
        fi
	;;
	LIST)
        /bin/grep -q $var_name /share/CACHEDEV1_DATA/myprograms/shellinabox/user.lst
        if [ $? -ne 0 ] ; then
                echo "Hum! unknown name .... exit"
                exit 1
        fi
	;;
	*)
	if [ "$var_name" != "admin" ] ; then
                echo "Hum! Default ... only administrator user is authorize ... exit"
                exit 1
        fi
        ;;
esac
/share/CACHEDEV1_DATA/myprograms/shellinabox/bin/cnx_user -  $var_name 
if [ $? -eq 0 ] ; then
	echo "Bye bye"
else
	echo "Bad password or empty"
fi
exit
