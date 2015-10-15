#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
log=/share/CACHEDEV1_DATA/myprograms/autorun/autoruntest.log
stdlog=/share/CACHEDEV1_DATA/myprograms/autorun/autoruntest_std.log
log(){
	/bin/echo "$(/bin/date '+%F %T.%3N') $1" >> $log
#	printf "[4] %.23s" $(/bin/date +'%Y-%m-%dT%H:%M:%S.%N') >> $log
}
log "*** Starting autoruntest.sh"
exec > $stdlog 2>&1

log "PATH=$PATH"
log "Running command with stdout output"
/bin/ls -la
log "Running wrong command with stderr output"
gfrxls
log "*** End of autoruntest.sh"
