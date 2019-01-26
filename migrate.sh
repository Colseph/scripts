#!/usr/bin/env bash
#~crappily rebranded/slightly modified opt.sh
#~because im lazy


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
logFile=~/rclone_migrations.log

#~db folder
#~	as the download id env var isnt set when the path is, we need a way to save the download id durning the download run
#~	then it will loop through the hashes, and work with rtorrent to see what needs to be moved
dbFolder=~/rclone_migrations_db

#~ TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
#~TODO i am very lost with how i am gonna organize paths... somehow make it dynamic AND STABLE and nice.TODO
#~ TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
#~[base path]s
remoteBase=nyanyancrypt-write:
#~remote base - can be to a mount or an rclone remote ie gdrive:path
#~using a cache is recommended(or you might get nothing but input/output errors.... .............. .... ugh..)
remoteBase=nyanyancrypt-write
#~remote plex - remote dir that plex scans
#~i added this because on my build, plex reads from plexdrive readonly mount, so my write directory is different
remotePlex=/datapool/nyanyancrypt-read/plex

#~[libraries]
#~to find the library IDs run the 'Plex Media Scanner' w/ -l or --list arguments
#~ example: just quote for spaces
#~	declare -a libs=(["anime tv"]=11 [tv]=8 [movies]=9 [music/main]=10 [nsfw/hentai]=13 [nsfw/movies]=12 [nsfw/tv]=14)
#~remember to put the library FOLDER, not the name
unset libs
declare -a libs=([anime_tv]=11 [tv]=8 [movies]=9 [music/main]=10 [nsfw/hentai]=13 [nsfw/movies]=12 [nsfw/tv]=14)

#~plex env vars and plex scanner bin(for clenliness in main stript)
#~these are the ones for my arch install, yours may be different
#~(you can probs get them or find where they are from the service file)
setEnv="export LD_LIBRARY_PATH=/usr/lib/plexmediaserver export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plex"
pScan="/usr/lib/plexmediaserver/Plex Media Scanner"

#~~~~~~~~~~~~~#
#~ functions ~#
#~~~~~~~~~~~~~#

_log() {
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

_movePlexData() {
	#~rclone moves plex library folder to cloud (ignoring Plex Versions folder as opt.sh should be taking care of that)
	rclone move --exclude "Plex Versions/*" "$mediaPath" "$remoteLib"
	ecode=$?
	_log date "[movePlexData]rclone move finished with result of $ecode"
}

_getTorrentInfo() {
	#~gets info from rTorrent for supplied hash
	hashTable["$1:state"]=$(echo xmlrpc returndata)
	hashTable["$1:path"]=$(echo xmlrpc returndataPATH)
	hashTable["$1:name"]=$(echo xmlrpc returndataNAME)
}

_preTorrentMove() {
	#~pauses torrent
	echo xmlrpc pause
	ecode=$?
	_log date "[movePlexData]rclone move finished with result of $ecode"
}

_postTorrentMove() {
	#~changes rtorrent path to new path, then resumes(hopefully w/o rechecking......)
	echo xmlrpc change path
	ecode=$?
	_log date "[postTorrentMove]changing path finished with result of $ecode"
	echo xmlrpc resume
}

_moveTorrentData() {
	#~slightly more advanced, moves torrent files to cloud
	_preTorrentMove $1
	remoteTorrentLib=$(echo sed replace )
	rclone move "${hashTable["$1:path"]}" "$remoteLib"
	ecode=$?
	_log date "[moveTorrentData]rclone move finished with result of $ecode"
	_postTorrentMove
}

_scanPlex() {
	su plex -c "$setEnv; '$pScan' -s -c $libID -d '$plexLib'"
}
#~~~~~~~~~~~~~~~~~~~~~#
#~ Pre Script Checks ~#
#~~~~~~~~~~~~~~~~~~~~~#
#~TODO check paths
#~checks some paths, and sets some variables

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~ [insert japanglish 'skuriputo sutaato' here] ~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~lock file(so you dont have 2 instances at once)
#~TODO change to while lockfile exists sleep wait
[ -e ~/opt.sh.lock ] && _log date "another instance started but found lock file. --> EOF" && exit ||\
	_log begin && _log date "lock file not found, creating '~/opt.sh.lock' and continuing." && touch ~/opt.sh.lock

_log date "getting and checking Env Vars:"
#sonarr sends args: sonarr series
#radarr sends args: radarr movie
#lidarr sends args: lidarr artist
runBy=$1
_log "runBy='$runBy'"
mediaType=$2
_log "mediaType='$mediaType'"
eventType=$(temp=${runBy}_eventtype; printf "${!temp}")
_log "eventType='$eventType'"
mediaID=$(temp=${runBy}_${mediaType}_id; printf "${!temp}")
_log "mediaID='$mediaID'"
downloadID=$(temp=${runBy}_download_id; printf "${!temp}")
_log "downloadID='$downloadID'"
mediaPath=$(temp=${runBy}_${mediaType}_path; printf "${!temp}")
_log "mediaPath='$mediaPath'"

#~sets Plex Library variables
#~the rtorrent remote vars are set in the _moveTorrentData func
#~local plex library is mediaPath
#~gets plex folder by stripping localBase off of mediaPath
plexFolder=$(echo sed replace base path w/ null for mediaPath)
remoteLib="$remoteBase/$plexFolder"
plexLib="$plexBase/$plexFolder"
libID=${libs["$plexFolder"]}


if [ "$eventType" == "Download" ]; then
	#~saves has to $mediaID.db file
	_log date "Saving hash: '$downloadID' to $dbFolder/$mediaID.db"
	echo "$downloadID" >> "$dbFolder/$mediaID.db"
elif [ "$eventType" == "Rename" ]; then
	#~heres where the big work is done.
	_log date "moving Plex data to cloud"
	_movePlexData
	
	_log date "Processing Hashes"
	unset hashTable
	declare -A hashTable
	#~^^ lol its funny because its a HASH table.. 
	for dlHash in `cat "$dbFolder/$mediaID.db"`; do
		log ""
		log "processing: $dlhash"
		_getTorrentInfo $dlHash
		_log "state: ${hashTable["$dlHash:state"]}"
		_log "path: ${hashTable["$dlHash:path"]}"
		_log "name: ${hashTable["$dlHash:name"]}"
		#~see if path is local && rottent is complete(skips if both conditions not met
		#~this way if 2 are qeued and the first one finished both, then the second will be like "ok cool thanks bro"
		#~but the second will still have to move the plex data.
		if [ "" == "" ] &&
		[ "" == "" ]; then
			#~passed both tests, moves to cloud
			_log date "Moving Torrent Data for $dlHash"
			_moveTorrentData $dlHash
		else
			_log date "Conditions not met, skipping $dlHash"
		fi
	done
	#~waits until now to scan plex so mounts have time to sync
	_scanPlex
else
	log date "unneeded runType: $runType. skipping..."
fi
			

for index in ${!libs[@]}; do
	#~assign vars for current index so its easier to understand the next bit
	localLib="$localBase/${libs[$index]#*$delim}/Plex Versions"
	remoteLib="$remoteBase/${libs[$index]#*$delim}/Plex Versions"
	plexLib="$plexBase/${libs[$index]#*$delim}"
	libID=${libs[$index]%$delim*}


	#~checks if conditions are met to move to cloud
	#~files exist
	if [ -n "$(find "$localLib/" -type f 2>/dev/null)" ] && 
	#~none of the files that exist are in progress
	[ -z "$(find "$localLib/" -type f -path '*/.inProgress/*' 2>/dev/null)" ]; then

		#~moves local to remote and writes to log
		_log date "[${libs[$index]}]: Conditions met for move"
		#~scan directory
		#~lol took a little while to get the quoting to work right
		#~sleeps first to allow cloud to sync/update different mounts
		_log date "[${libs[$index]}]: sleeping $slp seconds to allow cloud-sync"
		sleep $slp
		_log date "[${libs[$index]}]: Calling Plex Scanner w/ args '-s -c $libID -d $remoteLib'"
	else
		#~does nothing - and wirtes to log
		_log date "[${libs[$index]}]: Conditions NOT met: Skipping.."
	fi
done
_log date "removing lock file '~/opt.sh.lock'"
rm ~/opt.sh.lock
_log end
