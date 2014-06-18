#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution

alias ts='/home/telemarch'
AUTORUNLOG=/home/telemarch/autorun/autoruntest.log
PIPEFILE=autoruntest_sh_pipe
# create named pipe
mkfifo $PIPEFILE
# Start ts writing to a logfile, but pulling its input from our named pipe.
ts "%F %H:%M:%.S" >> $AUTORUNLOG < $PIPEFILE &
# capture ts's process ID for the wait command.
TS_PID=$!
# redirect the rest of the stderr and stdout to our named pipe.
exec > $PIPEFILE 2>&1
echo "*** Starting autoruntest.sh"
echo "PATH=$PATH"
echo "PID of ts: $TS_PID"
echo "Calling another script subscript.sh"
/home/telemarch/autorun/subscript.sh
echo "subscript script done."

echo "Closing output redirection to log file"
# close the stderr and stdout file descriptors.
exec 1>&- 2>&-

# Wait for ts to finish since now that other end of the pipe has closed.
wait $TS_PID
#delete named pipe when finished
trap 'rm "$PIPEFILE"' EXIT
echo "*** End of autoruntest.sh" | ts "%F %H:%M:%.S" >> $AUTORUNLOG
