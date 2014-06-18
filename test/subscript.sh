#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
log=/home/telemarch/autorun/subscript.log
namedpipe=/home/telemarch/autorun/subscript_sh_pipe
alias ts='/home/telemarch/sbin/ts'
echo "*** Starting subscript.sh"  | ts "%F %H:%M:%.S" >> $log
if [ -p $namedpipe ]; then
	echo "Named pipe $namedpipe exists. Deleting." | ts "%F %H:%M:%.S" >> $log
	rm -f "$namedpipe"
fi
# create named pipe
mkfifo $namedpipe
# Start ts writing to a logfile, but pulling its input from our named pipe.
ts "%F %H:%M:%.S" >> "$log" < "$namedpipe" &
# capture ts's process ID for the wait command.
ts_pid=$!
# redirect the rest of the stderr and stdout to our named pipe.
exec > $namedpipe 2>&1
echo "PID of ts: $ts_pid"

find ~/winnt -printf "%p\t%TY-%Tm-%Td %TH:%TM:%TS\n" | grep .xml
echo "Sleeping some seconds..."
sleep 10
echo "Wait for PID of ts: $ts_pid"
echo "Closing output redirection to log file"
# close the stderr and stdout file descriptors.
exec 1>&- 2>&-
# Wait for ts to finish since now that other end of the pipe has closed.
wait $ts_pid
#delete named pipe when finished
trap 'rm "$namedpipe"' EXIT
echo "*** End of subscript.sh" | ts "%F %H:%M:%.S" >> $log

