#!/opt/bin/bash
# script called by cron
mainlog=/share/CACHEDEV1_DATA/myprograms/backupjob/backupjob.log
exec &> $mainlog
echo "[$(/bin/date '+%F %T.%3N')] exiftool-job.sh STARTED ***********************"
timestamp_log() { 
	while IFS='' read -r line
		do /bin/echo "[$(/bin/date '+%F %T.%3N')] $line" >> "$1"
	done
}
#redirect sterr to stdout and then stdout to function
exec 2>&1> >(timestamp_log $mainlog)
/bin/echo "PATH: $PATH"
dirlist=( "/share/CACHEDEV1_DATA/Public/FOTOS/Subida automática Dani"
		  "/share/CACHEDEV1_DATA/Public/FOTOS/Subida automática Sonia" )

for item in "${dirlist[@]}" ; do
	directory="$item/Camera/"
	/bin/echo "Processing directory: $directory"
	/bin/echo "***Executing command: exiftool -d %Y-%m/%Y.%m.%d-%H%M%S.[%f]%%-c.%%e" '"-testname<CreateDate"' "$directory"
	exiftool -d %Y-%m/%Y.%m.%d-%H%M%S.[%f]%%-c.%%e "-testname<CreateDate" $directory
done

#exiftool -d %Y%m%d_%H%M%%-c.%%e "-filename<CreateDate" DIR

#Test rename but keep original filename:
#exiftool -d %Y%m%d_%H%M%S[%f]%%-c.%%e "-testname<CreateDate" Camera/
#exiftool -d %Y-%m/%Y%m%d_%H%M%S[%f]%%-c.%%e "-testname<CreateDate" Camera/
exiftool -d %Y-%m/%Y.%m.%d-%H%M%S.[%f]%%-c.%%e "-testname<CreateDate" Camera/
