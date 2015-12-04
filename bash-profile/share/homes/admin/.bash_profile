# .bash_profile
echo ".bash_profile invoked" > ~/bash_profile.out  
export PATH=\
/bin:\
/sbin:\
/usr/bin:\
/usr/sbin:\
/usr/bin/X11:\
/usr/local/bin

echo "export PATH=$PATH" >> ~/bash_profile.out
umask 022

if [ -f ~/.bashrc ]; then
    echo "sourcing ~/.bashrc" >> ~/bash_profile.out
    source ~/.bashrc
fi

if [ -f /opt/etc/profile ]; then
    echo "sourcing /opt/etc/profile" >> ~/bash_profile.out
    source /opt/etc/profile
fi

