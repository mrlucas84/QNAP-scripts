#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
log=/home/telemarch/autorun/autoruntest.log
stdlog=/home/telemarch/autorun/autoruntest_std.log
echo "$(date '+%F %T') *** Starting autoruntes.sh" >> $log
#namedpipe=/home/telemarch/autorun/autoruntest_sh_pipe
#alias ts='/home/telemarch/sbin/ts'
#if [ -p $namedpipe ]; then
#	echo "Named pipe $namedpipe exists. Deleting."
#	rm -f "$namedpipe"
#fi
## create named pipe
#mkfifo $namedpipe
## Start ts writing to a logfile, but pulling its input from our named pipe.
#ts "%F %H:%M:%.S" >> "$log" < "$namedpipe" &
## capture ts's process ID for the wait command.
#ts_pid=$!
## redirect the rest of the stderr and stdout to our named pipe.
#exec > $namedpipe 2>&1
exec > $stdlog 2>&1
echo "$(date '+%F %T') *** Starting autoruntest.sh" >> $log

echo "$(date '+%F %T') PATH=$PATH" >> $log
#echo "$(date '+%F %T') PID of ts: $ts_pid"
#echo "Calling another script subscript.sh"
#/home/telemarch/autorun/subscript.sh &
# echo "subscript.sh done."

#echo "Closing output redirection to log file"
## close the stderr and stdout file descriptors.
#exec 1>&- 2>&-
#
## Wait for ts to finish since now that other end of the pipe has closed.
#wait $ts_pid
##delete named pipe when finished
#trap 'rm "$namedpipe"' EXIT
echo "$(date '+%F %T') *** End of autoruntest.sh" >> $log
