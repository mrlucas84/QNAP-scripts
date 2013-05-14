#!/bin/bash

# A pretend Python dictionary with bash 3 
ARRAY=( "gitlab:ld"
		"gitlab_init:lo"
		"git-prompt2.sh:lh"
		"git-prompt3.sh:lh"
		"git-prompt.sh:lh"
		"history.txt:lo"
		"testmail.txt:lo"
		"teststruct.sh:lh")

for element in "${ARRAY[@]}" ; do
    DIRECTORY=${element%%:*}
    OPTION=${element#*:}
    #printf "ls -%s %s\n" "$OPTION" "$DIRECTORY" 
    ls -"$OPTION" "$DIRECTORY" 
done

#echo -e "${ARRAY[0]%%:*} is a directory so the command switch should contain d: ${ARRAY[0]#*:}\n"