#!/bin/sh

EXECUTABLE="/share/HDA_DATA/kms-vlmcsd/vlmcsd"
INIFILE="/share/HDA_DATA/kms-vlmcsd/vlmcsd.ini"
PIDFILE="/share/HDA_DATA/kms-vlmcsd/vlmcsd.pid"
LOGFILE="/share/HDA_DATA/kms-vlmcsd/vlmcsd.log"
LISTENPORT="1688"

if [ ! -f $EXECUTABLE ] || [ ! -f $INIFILE ]; then
                echo "Check variables in init daemon or missing files"
                exit 1
fi


case "$1" in
        start)
                #Start daemon
                if [ ! -f $PIDFILE ]; then

                        
                        $EXECUTABLE -i $INIFILE -p $PIDFILE -P $LISTENPORT -l $LOGFILE &
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
                                echo "Please check Pid file or user forcestart to overwrite pid"
                        fi

                fi
        ;;

        stop)
                #Stop Daemon
                if [ -f $PIDFILE ]; then
                        PID=`cat $PIDFILE`
                        kill $PID
                        rm $PIDFILE
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
                rm $PIDFILE
                $0 start
                exit 0
        ;;

        *)
                echo "Usage: $0 start|stop|restart|forcestart"
                exit 0
        ;;
        esac