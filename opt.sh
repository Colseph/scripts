#!/usr/bin/env bash

#~TODO verify path variables work w/ spaces etc..

: '
this script is for moving / rescanning plex optimized versions for rclone mount
assumes your setup is as such:
	/[local base]/plex/[library folder]
	/[remote base]/plex/[library folder]
	then each library has both the local and remote folders added
	in the optimize options you choose the /[local base]/plex/[library folder]
how it works:
	- plex will make the optimized version in the local dir(not spamming out in the cloud)
	- then this script will be run every x min. this script will only something both of the
	  following conditions are met:
		1 - there are optimized versions on local, that need to be moved to cloud
		2 - no in progress conversions(no files exist in .inProgress dirs)
	  (this is to help with google api limit)
	- rclone moves /[local base]/plex/[library folder]/Plex Versions to
		/[remote base]/plex/[library folder]/Plex Versions
	- then it uses Plex Media Scanner to scan only the Plex Versions folder
	  in the corrisponding library(what the Section ID is needed for)
'

#~ youll need to fill in your library IDs and FOLDERs(not names) in the config section below.
#~to find the library IDs either run the 'Plex Media Scanner' w/ -l arg

#~~~~~~~~~~#
#~ Config ~#
#~~~~~~~~~~#

#~log file (set to '/dev/null' if u dont want logging
#~	or to '&1' [stdout] if your running from cron and you want emails
#~	feel free to make monthly logs to ie: logFile=optimizations_`date +%Y-%m`.log
logFile=~/optimizations.log

#~base paths
localBase=/media
#~remote needs to be path to mount if you use ie gdrive:media plex scanner wont know wheretf that is
remoteBase=/test/remote/path

#~delimiter (this is if your lib folder has a ':' in it you can change this to something else
#~obv if you change this, you need to change the ':' in the libs array too.
#~ example:
#~	delims=-
#~	libs=(1-movies 2-'tv shows')
delim=:

#~folders
#~ example: first w/ no spaces next two are options for quoting folders with spaces
#~	libs=(2:/movies 6:'/tv shows' "4:/other videos" 3:/anime_tv)
#~remember to put the library FOLDER, not the name
#~NOTE: you CANNOT lead w/ a space after the delim. ie '4: folder with space'
#~	it will always eval to true(and youll do un-needed scans)
libs=(5:/anime 3:Leading_slash_not_needed "4:thisis a test" 6:'this too')

#~plex env vars and plex scanner bin(for clenliness in main stript)
#~these are the ones for my arch install, yours may be different
#~(you can probs get them or find where they are from the service file)
export LD_LIBRARY_PATH=/usr/lib/plexmediaserver
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plex
pScan="/usr/lib/plexmediaserver/Plex Media Scanner"

#~~~~~~~~~~~~~#
#~ functions ~#
#~~~~~~~~~~~~~#

log() {
	#~just a log function
	#~case logic for nice formating
	case $1 in
		date)
			#~appends date to front
			printf '%s\n' "`date +%Y-%m-%d_%T` ---  $2" >> $logFile
			;;
		begin)
			#~signifies run start
			printf '%s\n' "-------------Run Start-------------" >> $logFile
			;;
		end)
			#~signifies run end
			printf '%s\n\n' "--------------Run end--------------" >> $logFile
			;;
		*)
			#~just logs
			printf '%s\n' "$@" >> $logFile
			;;
	esac
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~ [insert japanglish 'skuriputo sutaato' here] ~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~whole script iterates through libs
#~it actually loops through the array index so i can call the whole array value
#~where if i just looped through the array, it thinks the folders w/ spaces are different args
#~EVEN W/ QUOTING.. ugh bash..
log begin
for index in ${!libs[@]}; do
	#~assign vars for current index so its easier to understand the next bit
	localLib="$localBase/plex/${libs[$index]#*$delim}/Plex Versions"
	remoteLib="$remoteBase/plex/${libs[$index]#*$delim}/Plex Versions"
	libID=${libs[$index]%$delim*}


	#~checks if conditions are met to move to cloud
	#~files exist
	if [ -n "$(find "$localLib/" -type f 2>/dev/null)" ] && 
	#~none of the files that exist are in progress
	[ -z "$(find "$localLib/" -type f -path '*/.inProgress/*' 2>/dev/null)" ]; then

		#~moves local to remote and writes to log
		log date "[${libs[$index]}]: Conditions met for move"
		rclone move --exclude .inProgress/* "$localLib" "$remoteLib"
		ecode=$?
		log date "[${libs[$index]}]: rclone move finished with result of $ecode"
		log date "[${libs[$index]}]: Calling Plex Scanner w/ args '-s -c $libID -d $remoteLib'"
		#~scand directory
		"$pScan" -s -c $libID -d "$remoteLib"
	else
		#~does nothing - and wirtes to log
		log date "[${libs[$index]}]: Conditions NOT met: Skipping.."
	fi
done
log end
