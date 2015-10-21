#!/bin/sh
#/share/CACHEDEV1_DATA/myprograms/vlmcsd/vlmcsd.sh

EXECUTABLE="/share/CACHEDEV1_DATA/myprograms/vlmcsd/vlmcsd"
INIFILE="/share/CACHEDEV1_DATA/myprograms/vlmcsd/vlmcsd.ini"
PIDFILE="/share/CACHEDEV1_DATA/myprograms/vlmcsd/vlmcsd.pid"
LOGFILE="/share/CACHEDEV1_DATA/myprograms/vlmcsd/vlmcsd.log"
USEIPv4="-4"
USEIPv6=
LISTENPORT="1688"

if [ ! -f $EXECUTABLE ] || [ ! -f $INIFILE ]; then
	echo "Check variables in init daemon or missing files"
	exit 1
fi

case "$1" in
		start)
			#Start daemon
			if [ ! -f $PIDFILE ]; then
				$EXECUTABLE -i $INIFILE -p $PIDFILE $USEIPv4 $USEIPv6 -P $LISTENPORT -l $LOGFILE &
				echo "KMS Has been started"
				exit 0
			else
				PID=`cat $PIDFILE`
				kill -s 0 $PID
				RESULT=$?
				if [ -f $PIDFILE ] && [ $RESULT -eq 0 ]; then
					echo "KMS Server is already running"
					exit 2
				else
					echo "Please check pid file or use forcestart to overwrite pid"
				fi
			fi
		;;

		stop)
			#Stop Daemon
			if [ -f $PIDFILE ]; then
				PID=`cat $PIDFILE`
				kill $PID
				if [ -f $PIDFILE ]; then
					rm $PIDFILE
				fi
				echo "KMS Has been stopped"
				exit 0
			else
				echo "KMS is not running"
				exit 1
			fi
		;;

		restart)
			$0 stop
			$0 start
		;;

		forcestart)
			if [ -f $PIDFILE ]; then
				rm -f $PIDFILE
			fi
			$0 start
			exit 0
		;;

		*)
			echo "Usage: $0 start|stop|restart|forcestart"
			exit 0
		;;
esac