#!/usr/bin/env bash
#~crappily rebranded/slightly modified opt.sh
#~because im lazy
#~^lol it actually is hardly like opt.sh anymore but oh well

#~TODO add docs


#~~~~~~~~~~#
#~ Config ~#
#~~~~~~~~~~#

#~log file (set to '/dev/null' if u dont want logging
#~	or to '&1' [stdout] if your running from cron and you want emails
#~	feel free to make monthly logs too ie: logFile=optimizations_`date +%Y-%m`.log
logFile=~/rclone_migrations.log

#~torrentDB - where to save .torrent files(both normal and fast_resume)
#~structure will be as so: 
#~	└── [torrentDB]
#~	    └── [torrentName]
#~		├── fast_resume_[torrentHash].torrent <--this is the fastResume one
#~		└── [torrentName].torrent <--this is the normal one
torrentDB=/datapool/gDrive/rtorrent/.torrentdb

#~sleepTime - time to wait for mounts to sleep in seconds
#~needed if using seperate mounts for reading/writing
sleepTime=300


#~[base path]s
localBase=/datapool/local
#~remote mount NEEDS to be in gdrive:path format, or youll get nothing but input output errors
#~this means you either need all lidarr/sonarr/radarr do have rclone config setup
#~or you make an rclone account and allow other users to sudo -u w/out passowrd
#~thats how i have it stup for me so youll need to change the code below
#~just search for 'rclone'
remoteBase=gDrive:
#~remote plex - remote dir that plex scans
#~i added this because on my build, plex reads from plexdrive readonly mount, so my write directory is different
plexDrive=/datapool/plexdrive

#~[libraries]
#~to find the library IDs run the 'Plex Media Scanner' w/ -l or --list arguments
#~ example: just quote for spaces
#~	declare -A libs=([anime_tv]=11 [tv]=8 [movies]=9 [music/main]=10 [nsfw/hentai]=13 [nsfw/movies]=12 [nsfw/tv]=14)
#~remember to put the library FOLDER, not the name
unset libs
declare -A libs=([anime_tv]=11 [tv]=8 [movies]=9 [music]=10)

#~plex env vars and plex scanner bin(for clenliness in main stript)
#~these are the ones for my arch install, yours may be different
#~(you can probs get them or find where they are from the service file)
#~you need to let any user su as plex in sudoers file
#~because this script gets run by sonarr/radarr/lidarr etc not root
setEnv="export LD_LIBRARY_PATH=/usr/lib/plexmediaserver export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plex"
pScan="/usr/lib/plexmediaserver/Plex Media Scanner"

#~fastResume perl script (get it form rtorrent github)
fastResume="/rtorrent/rtorrent_fast_resume.pl"

#~rtorrent session location(needed to get torrent files for fast resume)
torrentSession="/rtorrent/.session"

#~rpc path for rtorrent
#~example "localhost:8080/RPC2
rpcPath=localhost:8080/RPC

#~random script identifier - used to identify different instances running at the same time etc..
#~you could probs set this as the PID
scriptID=$(printf '%04d' "$((RANDOM%1000+1))")

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
			printf '%s\n' "-------------runStart[$scriptID]-------------" >> $logFile
			;;
		end)
			#~signifies run end
			printf '%s\n\n' "--------------runEnd[$scriptID]--------------" >> $logFile
			;;
		*)
			#~just logs
			printf '%s\n' "$@" >> $logFile
			;;
	esac
}

_checkDirectory() {
	#~just checks if directory exists, if not, its made
	[ -e "$1" ] || mkdir -p "$1"
}

_escapeString() {
	#~escapes regex special characters for rclone
	#~thankyou printf and your godly %q
	_log date "[escapeString]escaping '$1'"
	unset escapedString
	escapedString=$(printf '%q' "$1")
	_log "[escapeString]returned '$escapedString'"
}

_movePlexData() {
	#~rclone moves plex library folder to cloud (ignoring Plex Versions folder as opt.sh should be taking care of that)
	_log date "[movePlexData]moving Plex Data"
	_escapeString "${mediaPath#"$localBase"}"
	_log "[movePlexData]FLAGS: --include '$escapedString**' --filter '- Plex Versions/*' move '$localBase' --> '$remoteBase'"
	sudo -u rclone rclone --include "$escapedString**" --filter  "- Plex Versions/*" move "$localBase" "$remoteBase"
	ecode=$?
	_log date "[movePlexData]rclone move finished with result of $ecode"
}

_getTorrentInfo() {
	#~gets info from rTorrent for supplied hash
	#~idk if theres a way to only return value, so i gotta strip extra stuff
	#~i was gonna print "'(.*)'" substring but if the name has single quotes
	#~basic bash expansion will only strip the outer ones and work
	temp=$(xmlrpc $rpcPath d.complete "$1")
	hashTable["$1:state"]=${temp#*"integer: "}
	temp=$(xmlrpc $rpcPath d.directory "$1")
	temp=${temp#*\'}
	hashTable["$1:basePath"]=${temp%\'}
	temp=$(xmlrpc $rpcPath d.base_path "$1")
	temp=${temp#*\'}
	hashTable["$1:fullPath"]=${temp%\'}
	temp=$(xmlrpc $rpcPath d.name "$1")
	temp=${temp#*\'}
	hashTable["$1:name"]=${temp%\'}
}

_preTorrentMove() {
	#~creates fast_resume .torrent file and moves plain torrent in .torrentDB
	_log date "[preTorrentMove]creating fast_resume torrent for $1"
	_checkDirectory "$torrentDB/${hashTable["$1:name"]}"
	"$fastResume" "${hashTable["$1:basePath"]}" "$torrentSession/$1.torrent" "$torrentDB/${hashTable["$1:name"]}/fast_resume_$1.torrent"
	_log date "[preTorrentMove]keeping original torrent as '$torrentDB/${hashTable["$1:name"]}/${hashTable["$1:name"]}.torrent'"
	cp "$torrentSession/$1.torrent" "$torrentDB/${hashTable["$1:name"]}/${hashTable["$1:name"]}.torrent"
	#~idk do i need to pause/change dir now?
	torrentBasePath="${hashTable["$1:basePath"]}"
	_log date "[preTorrentMove]changing torrent directory to '$plexDrive/${torrentBasePath#"$localBase"}'"
	xmlrpc $rpcPath d.directory.set "$1" "$plexDrive/${torrentBasePath#"$localBase"}"
}

_postTorrentMove() {
	#~uses fast_resume torrent to start seeding agian w/ new path
	_log date "[postTorrentMove]fast_resume $1"
	xmlrpc $rpcPath load.start "$1" "$torrentDB/${hashTable["$1:name"]}/fast_resume_$1.torrent"
	ecode=$?
	_log date "[postTorrentMove]fast_resume load completed with result: $ecode"
	_log "opening $1"
	xmlrpc $rpcPath d.open "$1"
	ecode=$?
	_log date "[postTorrentMove]fast_resume open completed with result: $ecode"
	_log "starting $1"
	xmlrpc $rpcPath d.start "$1"
	ecode=$?
	_log date "[postTorrentMove]fast_resume start completed with result: $ecode"
}

_moveTorrentData() {
	#~slightly more advanced, moves torrent files to cloud
	_log date "[moveTorrentData]Preparing to move Torrent Data"
	_log "[moveTorrentData]HASH: $dlHash"
	_preTorrentMove $dlHash

	torrentFullPath="${hashTable["$dlHash:fullPath"]}"
	_escapeString "${torrentFullPath#"$localBase"}"
	_log date "[moveTorrentData]Moving Torrent Data"
	sudo -u rclone rclone --include "$escapedString**" move "$localBase" "$remoteBase"
	ecode=$?
	_log date "[moveTorrentData]rclone move finished with result of $ecode"
	_log date "[moveTorrentData]sleeping for $sleepTime seconds to allow mount sync"
	sleep $sleepTime
	_postTorrentMove $dlHash
}

_scanPlex() {
	#su plex -c "$setEnv; '$pScan' -s -c $libID -d '$plexScanPath'"
	_log date "[scanPlex]scanning plex dir '$plexScanPath'"
	sudo -u plex bash -c "$setEnv; '$pScan' -s -c $libID -d '$plexScanPath'"
	ecode=$?
	_log date "[scanPlex]Scanning finished with result of $ecode"
}
#~~~~~~~~~~~~~~~~~~~~~#
#~ Pre Script Checks ~#
#~~~~~~~~~~~~~~~~~~~~~#
#~checks some paths, and sets some variables
_checkDirectory "$torrentDB"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~ [insert japanglish 'skuriputo sutaato' here] ~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~lock file(so you dont have 2 instances at once)
[ -e ~/migrate.sh.lock ] && _log date "[main]another instance[$scriptID] started but found lock file. --> Waiting.." && while [ -e ~/migrate.sh.lock ]; do sleep $sleepTime; done && _log begin ||\
	_log begin && _log date "[main]lock file not found, creating '~/migrate.sh.lock' and continuing[$scriptID]." && touch ~/migrate.sh.lock

_log "Script ID='$scriptID'"
_log date "[main]getting and checking Env Vars:"
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
#downloadID=$(temp=${runBy}_download_id; printf "${!temp}")
#_log "downloadID='$downloadID'"
dlHash=$(temp=${runBy}_download_id; printf "${!temp}")
_log "dlHash='$downloadID'"
mediaPath=$(temp=${runBy}_${mediaType}_path; printf "${!temp}")
_log "mediaPath='$mediaPath'"

#~sets Plex Library variables
#~the rtorrent remote vars are set in the _moveTorrentData func
#~assumes that your library folders are unique
plexFolder=$(for i in ${!libs[@]}; do [[ "$mediaPath" == *"/$i/"* ]] && echo "$i"; done)
_log "plexFolder='$plexFolder'"
libID=${libs["$plexFolder"]}
_log "libID='$libID'"
#~replaces localBase path with plexDrive
plexScanPath="$plexDrive/${mediaPath#"$localBase"}"
#~appearantley plex scanner assumes each '/' is a directory.(so it thinks root//library/showname is an empty library with a show called library inside?...
#~ugh. anyways this fixes it.
plexScanPath="${plexScanPath/\/\//\/}"
_log "plexScanPath='$plexScanPath'"


if [ "$eventType" == "Download" ]; then
	#~heres where the big work is done.
	#~waits a LONG time(gives large batches time to import before the source files are moved etc..
	sleep 600
	_movePlexData
	
	_log date "[main]Processing Hash: $dlHash"
	unset hashTable
	declare -A hashTable
	#~^^ lol its funny because its a HASH table.. 
	_log ""
	_getTorrentInfo $dlHash
	_log "state: ${hashTable["$dlHash:state"]}"
	_log "fullPath: ${hashTable["$dlHash:fullPath"]}"
	_log "basePath: ${hashTable["$dlHash:basePath"]}"
	_log "name: ${hashTable["$dlHash:name"]}"
	#~see if path is local && rottent is complete(skips if both conditions not met
	#~sometimes script gets invoked twice? this stops it from clobbering stuff
	if [[ "${hashTable["$dlHash:basePath"]}" == *"$localBase"* ]] &&
	[ "${hashTable["$dlHash:state"]}" == "1" ]; then
		#~passed both tests, moves to cloud
		_moveTorrentData
	else
		_log date "[main]Conditions not met, skipping $dlHash"
		_log "invoked twice?"
	fi
	#~waits until now to scan plex so mounts have time to sync
	_scanPlex
else
	_log date "[main]unneeded runType: $eventType. skipping..."
fi
_log date "[main]removing lock file ~/migrate.sh.lock"
rm ~/migrate.sh.lock
ecode=$?
_log "[main]lock remove completed with result: $ecode"
_log end
