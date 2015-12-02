echo "[$(/bin/date '+%F %T.%3N')] .profile invoked **************" >> ~/profile.out 
echo -n "[$(/bin/date '+%F %T.%3N')] shell type: " >> ~/profile.out
[[ $- == *i* ]] && echo -n 'Interactive' >> ~/profile.out || echo -n 'Not interactive' >> ~/profile.out
echo -n " - " >> ~/profile.out
shopt -q login_shell && echo 'Login shell' >> ~/profile.out || echo 'Not login shell' >> ~/profile.out
echo "[$(/bin/date '+%F %T.%3N')] PATH=$PATH" >> ~/profile.out

export PS1='[\w] # '
reset
