#!/bin/bash

timestamp_log() { while IFS='' read -r line; do echo "[$(date '+%F %T')] $line" >> "$1"; done; };
#timestamp_log() { while IFS='' read -r line; do echo "[$(date '+%F %T')] $line" | tee -a "$1" > /dev/null; done; };

MAINLOG=./backupjob.log
RSYNCLOG=./backupjob-rsync.log
     
SKIPZLIST="7z/7Z/tbz/tgz/z/zip/ZIP/rar/RAR/bz2/rpm/deb/gz/iso/ISO/jpeg/JPEG/jpg/JPG/avi/AVI/mov/MOV/mkv/MKV/mp[34]/MP[34]/ogg/flac/FLAC/pdf/PDF/bin/BIN/exe/EXE"

#DRYRUN="--dry-run"
COMMANDS[0]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/FOTOS Dani@$rsyncd_hostname::nasbackup"
COMMANDS[1]="/opt/bin/rsync -vrtz $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/Documentos Dani@$rsyncd_hostname::nasbackup"
COMMANDS[2]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/PDF Dani@$rsyncd_hostname::nasbackup"
COMMANDS[3]="/opt/bin/rsync -vrt  $DRYRUN --skip-compress=$SKIPZLIST --chmod=ugo=rwX --delete /share/HDA_DATA/Public/MUSICA Dani@$rsyncd_hostname::nasbackup"

ARRAY=( "gitlab:ld"
		"gitlab_init:lo"
		"git-prompt2.sh:lh"
		"git-prompt3.sh:lh"
		"git-prompt.sh:lh"
		"history.txt:lo"
		"testmail.txt:lo"
		"teststruct.sh:lh" )

#redirect sterr to stdout and then stdout to function
exec 2>&1> >(timestamp_log $MAINLOG)
echo "Starting backupjob.sh"

error_rc=0

for item in "${ARRAY[@]}" ; do
    DIRECTORY=${item%%:*}
    OPTION=${item#*:}
	
	echo "Listing: $DIRECTORY"
	
	exec 2>&1> >(timestamp_log $RSYNCLOG)
	echo "Executing command: ls -$OPTION $DIRECTORY"
    ls -"$OPTION" "$DIRECTORY"
	
	exec 2>&1> >(timestamp_log $MAINLOG)
	return_code=$?
	if [[ $return_code -ne 0 ]] ; then
		error_rc=return_code
		echo "Error in task." 
	fi
done

if [[ $error_rc -eq 0 ]] ; then
	echo "All tasks finished successfully."
else
	echo "Some tasks DID NOT finished successfully."
fi
echo "Done. Exit."
exit 1
