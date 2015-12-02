# .bash_profile
echo "[$(/bin/date '+%F %T.%3N')] .bash_profile invoked **************" >> ~/bash_profile.out 
echo -n "[$(/bin/date '+%F %T.%3N')] shell type: " >> ~/bash_profile.out
[[ $- == *i* ]] && echo -n 'Interactive' >> ~/bash_profile.out || echo -n 'Not interactive' >> ~/bash_profile.out
echo -n " - " >> ~/bash_profile.out
shopt -q login_shell && echo 'Login shell' >> ~/bash_profile.out || echo 'Not login shell' >> ~/bash_profile.out

export PATH=\
/bin:\
/sbin:\
/usr/bin:\
/usr/sbin:\
/usr/bin/X11:\
/usr/local/bin

echo "[$(/bin/date '+%F %T.%3N')] export PATH=$PATH" >> ~/bash_profile.out
umask 022

if [ -f ~/.bashrc ]; then
	echo "[$(/bin/date '+%F %T.%3N')] sourcing ~/.bashrc" >> ~/bash_profile.out
    source ~/.bashrc
fi
[ -f /opt/etc/profile ] && echo "[$(/bin/date '+%F %T.%3N')] sourcing /opt/etc/profile" >> ~/bash_profile.out && source /opt/etc/profile
