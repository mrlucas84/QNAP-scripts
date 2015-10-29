#!/bin/sh
# con /opt/bin/bash parece que no se lanza en boot
# con /bin/sh no funciona el redireccionamiento a funcion/process substitution
# this is called by /tmp/config/autorun.sh mounted from /dev/mtdblock6 (ubifs)
# mount with /share/CACHEDEV1_DATA/myprograms/autorun/cfgdev.sh (/sbin/hal_app --get_boot_pd port_id=0)
# /share/CACHEDEV1_DATA/myprograms/autorun

log=/share/CACHEDEV1_DATA/myprograms/autorun/autorunmaster.log
log(){
	/bin/echo "$(/bin/date '+%F %T.%3N') $1" >> $log
}
log "***** Starting autorunmaster.sh *****"
apache_conf=/etc/config/apache/apache.conf
apache_custom_conf=/share/CACHEDEV1_DATA/myprograms/apache/apache-custom.conf

exec >> $log 2>&1

log "PATH=$PATH"
#check if link /dev/fd exists, if not, create it
#necessary for process substitution to work, see http://wiki.bash-hackers.org/syntax/expansion/proc_subst
# and see http://www.ducea.com/2009/02/18/linux-tips-bash-completion-devfd62-no-such-file-or-directory/
dev_fd=/dev/fd
if [ ! -e "$dev_fd" ]; then
	/bin/echo "$dev_fd does NOT exist. Creating link to /proc/self/fd to enable process substitution"
	/bin/ln -s /proc/self/fd "$dev_fd"
fi

log "Setting up custom scripts"

#sobreescribir config SSH con la propia 
# log "Delete /etc/ssh/sshd_config and recreate as symlink to /share/HDA_DATA/ssh/sshd_config"
# /bin/rm -f /etc/ssh/sshd_config
# /bin/ln -s /share/HDA_DATA/ssh/sshd_config /etc/ssh/sshd_config

#modificar configuracion apache. quiet grep search
/bin/grep -q $apache_custom_conf $apache_conf
if [ $? -eq 0 ]; then
	log "$apache_conf already includes $apache_custom_conf. Nothing to be done."
else
	log "$apache_conf does NOT include $apache_custom_conf. Including now."
	/bin/echo "Include $apache_custom_conf" >> $apache_conf
	log "Restarting apache"
	/etc/init.d/Qthttpd.sh restart
fi

# log "Copying /usr/local/etc/services to /etc/services"
# /bin/cp -f /usr/local/etc/services /etc/services
# /bin/sleep 2
# export Entware_TARGET=cs08q1armel
# log "Starting xinetd..."
# if [ -e "/opt/sbin/xinetd" ]
	# then
		# /sbin/daemon_mgr xinetd start "/opt/sbin/xinetd"
		# log "xinetd started"
		# sleep 5
	# else
		# log "xinetd not accessible"
# fi
log "***** End of autorunmaster.sh *****"
/bin/sync
/bin/sleep 1
