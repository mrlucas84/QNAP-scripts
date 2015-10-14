#!/bin/sh                                                                                                                                                        
# con /opt/bin/bash parece que no se lanza en boot                                                                                                               
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution                                                                                   
log=autoruntest.log                                                                                                                                              
stdlog=autoruntest_std.log                                                                                                                                       
log(){                                                                                                                                                           
        echo "[1] $(/bin/date '+%F %T.%3N') $1" >> $log                                                                                                          
        echo "" >> $log                                                                                                                                          
#       printf "[4] %.23s" $(date +'%Y-%m-%dT%H:%M:%S.%N') >> $log                                                                                               
}                                                                                                                                                                
log "*** Starting autoruntest.sh"                                                                                                                                
exec > $stdlog 2>&1                                                                                                                                              
                                                                                                                                                                 
log "PATH=$PATH"                                                                                                                                                 
log "Running command with stdout output"                                                                                                                         
ls -la                                                                                                                                                           
log "Running wrong command with stderr output"                                                                                                                   
gfrxls                                                                                                                                                           
log "*** End of autoruntest.sh"  