#!/bin/sh
# con /opt/bin/bash parece que no se lanza
# con /bin/sh no funciona el redireccionamiento a funcion
# this is called by autorun.sh
# /share/CACHEDEV1_DATA/myprograms/autorun/autorunmaster.sh

AUTORUNLOG=/share/CACHEDEV1_DATA/myprograms/autorun/autorunmaster.log
(
	set -x
	echo "$(/bin/date '+%F %T.%3N') Starting autorunmaster.sh"
	ls -alF /share/Public
	asdfasdf
	echo "End of autorunmaster.sh"
	set +x
# )2>&1|ts "%F %H:%M:%.S" >> $AUTORUNLOG
)2>&1 >> $AUTORUNLOG