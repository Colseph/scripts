#!/usr/bin/env bash


: '
this script is for moving / rescanning plex optimized versions for rclone mount
take a look at the config section before reading this so you understand better how it works

***using the plex scanner requires plex user, so you have two options:
	1. Run this script as is as root(or in roots crontab)(only do if you trust && understand this script)
	2. run as plex user(this will require modification to the plex scan line in the script)
		and you could also change the setEnv= line to just exporting the env variables
		youll also need to make sure the plex user has write access to remote locations
		and if you use a remote like "dgrive:path" youll need the remote to be added to the plex users rclone config

uses the following structure
	[base path]\[library]
		***the script assumes that the directory containing your libraries is the same across local, remote, and plex
		-the base path is the directory your libraries is located in
		-the library is the FOLDER of the libraries
	Examples:
		Two Drive mount point
		Folder structure as such:
			/
			├── 1localstorage
			│   └── plex
			│       ├── anime
			│       ├── movies
			│       └── Tv Shows
			├── googledrivemount(read+write)
			│   └── plex
			│       ├── anime
			│       ├── movies
			│       └── Tv Shows
			└── plexdrivemount(readonly)
			    └── plex
				├── anime
				├── movies
				└── Tv Shows
		Your config would look like:
			[base path]s
			localBase=/1localstorage/plex
			remoteBase=/googledrivemount(read+write)/plex
			plexBase=/plexdrive(readonly)/plex
			
			[libraries](see below how to get the IDs)
			libs=(5:/anime 3:"TV Shows" 4:movies)
		
		How it works:
		in plex each library should have both the plexdrivemount(readonly)/plex/[library] AND
			the 1localstorage/plex/[library] folders added
		
		then make an optimize job and select the 1localstorage/plex/[library] path
			
		plex will then optimize and save to 1localstorage/plex/[library]/Plex\ Versions/
		
		youd run this script every ~5-10min or so. the script would only do anything when both of the following
		conditions are met:
			-files exist in [library]Plex\ Versions/
			-files DO NOT exist in [library]/Plex\ Versions/*./.inProgress/
			basically only run if there are optimized versions and they are ALL finished/no in progress
			
		it would then rclone move everything from [local base]/[library]/Plex\ Versions/
			to [remote base]\[library]/Plex\ Versions/
		
		then it rould tell plex to scan the specified library(with the ID) but only the Plex\ Versions directory
		ie. Plex\ Media\ Scanner -s -c [libID] -d [plex base]/[library]/Plex\ Versions/
'


#~~~~~~~~~~#
#~ Config ~#
#~~~~~~~~~~#

#~log file (set to '/dev/null' if u dont want logging
#~	or to '&1' [stdout] if your running from cron and you want emails
#~	feel free to make monthly logs too ie: logFile=optimizations_`date +%Y-%m`.log
logFile=~/optimizations.log

#~delimiter (this is if your lib folder has a ':' in it you can change this to something else)
#~obv if you change this, you need to change the ':' in the libs array too.
#~ example:
#~	delims=-
#~	libs=(1-movies 2-'tv shows')
delim=:

#~[base path]s
localBase=/media
#~remote base - can be to a mount or an rclone remote ie gdrive:path
#~using a cache is recommended(or you might get nothing but input/output errors.... .............. .... ugh..)
remoteBase=gdrive:media
#~plex base - this might be the same as your remote base
#~i added this because on my build, plex reads from plexdrive readonly mount, so my write directory is different
plexBase=/datapool/plexdrive

#~[libraries]
#~to find the library IDs run the 'Plex Media Scanner' w/ -l or --list arguments
#~ example: first w/ no spaces next two are options for quoting folders with spaces
#~	libs=(2:/movies 6:'/tv shows' "4:/other videos" 3:/anime_tv)
#~remember to put the library FOLDER, not the name
#~NOTE: you CANNOT lead w/ a space after the delim. ie '4: folder with space'
#~	it will always eval to true(and youll do un-needed scans)
libs=(5:/anime 3:Leading_slash_not_needed "4:thisis a test" 6:'this too')

#~plex env vars and plex scanner bin(for clenliness in main stript)
#~these are the ones for my arch install, yours may be different
#~(you can probs get them or find where they are from the service file)
setEnv="export LD_LIBRARY_PATH=/usr/lib/plexmediaserver export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plex"
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
	localLib="$localBase/${libs[$index]#*$delim}/Plex Versions"
	remoteLib="$remoteBase/${libs[$index]#*$delim}/Plex Versions"
	plexLib="$plexBase/${libs[$index]#*$delim}/Plex Versions"
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
		#~scan directory
		#~lol took a little while to get the quoting to work right
		su plex -c "$setEnv; '$pScan' -s -c $libID -d '$plexLib'"
	else
		#~does nothing - and wirtes to log
		log date "[${libs[$index]}]: Conditions NOT met: Skipping.."
	fi
done
log end
