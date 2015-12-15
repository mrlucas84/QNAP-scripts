#!/opt/bin/bash
# script called by cron
log=/share/myprograms/exiftool/exiftool-job.log
exec &> $log
echo "[$(/bin/date '+%F %T.%3N')] exiftool-job.sh STARTED ***********************"
timestamp_log() {
	while IFS='' read -r line
		do echo "[$(/bin/date '+%F %T.%3N')] $line" >> "$1"
	done
}
#redirect sterr to stdout and then stdout to function
exec 2>&1> >(timestamp_log $log)
echo "PATH: $PATH"
dirlist=( "/share/CACHEDEV1_DATA/Public/FOTOS/Subida automática Dani/Camera/" 
	  "/share/CACHEDEV1_DATA/Public/FOTOS/Subida automática Sonia/100ANDRO/" )
basecmd='exiftool -d %Y-%m/%Y.%m.%d-%H%M%S.[%f]%%-c.%%e "-testname<CreateDate"'
for dir in "${dirlist[@]}" ; do
	echo "Processing directory: $dir"
#	cmd='$basecmd "$dir"'
	echo "***Executing command:" $basecmd "'$dir'"
	echo "-----------------------------------------------"
	sleep 1
	eval $basecmd "'$dir'"
done
echo "exiftool-job.sh FINISHED ***********************"
#exiftool -d %Y%m%d_%H%M%%-c.%%e "-filename<CreateDate" DIR

#Test rename but keep original filename:
#exiftool -d %Y%m%d_%H%M%S[%f]%%-c.%%e "-testname<CreateDate" Camera/
#exiftool -d %Y-%m/%Y%m%d_%H%M%S[%f]%%-c.%%e "-testname<CreateDate" Camera/
#exiftool -d %Y-%m/%Y.%m.%d-%H%M%S.[%f]%%-c.%%e "-testname<CreateDate" Camera/
