#!/bin/bash
configfile=./.myconfig
shopt -s extglob
while IFS='= ' read lhs rhs
do
    if [[ $line != *( )#* ]]
    then
        # you can test for variables to accept or other conditions here
        declare $lhs=$rhs
    fi
done < "$configfile"

echo "username: '$username'"
echo "target: '$target'"
echo "shell: '$shell'"
echo "email: '$email'"