# .bash_profile
# /share/homes/admin/.bash_profile
LOG=~/bash_profile.out
echo "[$(/bin/date '+%F %T.%3N')] .bash_profile invoked **************" >> $LOG 
echo -n "[$(/bin/date '+%F %T.%3N')] shell type: " >> $LOG
[[ $- == *i* ]] && echo -n 'Interactive' >> $LOG || echo -n 'Not interactive' >> $LOG
echo -n " - " >> $LOG
shopt -q login_shell && echo 'Login shell' >> $LOG || echo 'Not login shell' >> $LOG
export PATH=\
/bin:\
/sbin:\
/usr/bin:\
/usr/sbin:\
/usr/bin/X11:\
/usr/local/bin

echo "[$(/bin/date '+%F %T.%3N')] export PATH=$PATH" >> $LOG
umask 022

if [ -f ~/.bashrc ]; then
	echo "[$(/bin/date '+%F %T.%3N')] sourcing ~/.bashrc" >> $LOG
    source ~/.bashrc
fi

if [ -f /opt/etc/profile ]; then
	echo "[$(/bin/date '+%F %T.%3N')] sourcing /opt/etc/profile" >> $LOG
    source /opt/etc/profile
fi
