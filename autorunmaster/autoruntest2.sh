#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
log=./autoruntest.log
stdlog=./autoruntest_std.log
/bin/echo "$(/bin/date '+%F %T.%3N') *** Starting autoruntest.sh" >> $log
exec > $stdlog 2>&1

/bin/echo "$(/bin/date '+%F %T.%3N') PATH=$PATH" >> $log
/bin/echo "$(/bin/date '+%F %T.%3N') Running command with stdout output" >> $log
/bin/ls -la
/bin/echo "$(/bin/date '+%F %T.%3N') Running wrong command with stderr output" >> $log
gfrxls
/bin/echo "$(/bin/date '+%F %T.%3N') *** End of autoruntest.sh" >> $log