#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
log=autoruntest.log
stdlog=autoruntest_std.log
log(){
	echo "[1] $(/bin/date '+%F %T.%3N') $1" >> $log
# otra forma
#	d=$(date +'%Y-%m-%d %H:%M:%S|%N')
#	ms=$(( ${d#*|}/1000000 ))
#	d="${d%|*}.$ms"
#	echo "[2] $d $1" >> $log
# otra más esta con printf
#	timestamp = $(date '+%F %T.%N')
#	printf '%04d-%02d-%02dT%02d:%02d:%02d.%03d $1' \
#			$(date -r "${timestamp%.*}" +"%Y %m %d %H %M %S")\
#			$(( ${timestamp#*.}/1000 )) >> $log
	printf "[4] %.23s" $(date +'%Y-%m-%dT%H:%M:%S.%N') >> $log
	
	echo "" >> $log
}
log "*** Starting autoruntes.sh"
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
#echo "*** Starting autoruntest.sh"

log "PATH=$PATH"
#log "PID of ts: $ts_pid"
#echo "Calling another script subscript.sh"
#/home/telemarch/autorun/subscript.sh &
# echo "subscript.sh done."
log "Running command with stdout output"
ls -la
log "Running wrong command with stderr output"
gfrxls
#echo "Closing output redirection to log file"
## close the stderr and stdout file descriptors.
#exec 1>&- 2>&-
#
## Wait for ts to finish since now that other end of the pipe has closed.
#wait $ts_pid
##delete named pipe when finished
#trap 'rm "$namedpipe"' EXIT
log "*** End of autoruntest.sh"
