#!/usr/bin/env bash
#~encodes existting library to mp3
#~TODO add flag for extension(figure out metadata mapping for different formats?) 
#~so user can convert to any almost any format

#~ config ~#


#~ functions ~#

_help() {
    echo "
    usage:
    --help show this message

    -b bitrate for mp3 files
       defualt=320K

    -s source dir(the one w/ the non mp3s)
       default=./

    -d destination dir(where you want the mp3s)
       defualt=./mp3_converted
    "
}


#~ script_start ~#

while [ "$1" != "" ]; do
    case $1 in
        *help)
            _help
            exit
           ;;
       -b)
           shift
           bitrate="$1"
           ;;
       -s)
           shift
           sourceDir="$1"
           ;;
       -d)
           shift
           destDir="$1"
           ;;
       *)
           echo "unknown option: '$1'"
           _help
           exit 1
           ;;
   esac
   shift
done
#defaults
bitrate="${bitrate:-320K}"
sourceDir="${sourceDir:-.}"
destDir="${destDir:-./mp3_converted}"

echo source:$sourceDir
echo dest:$destDir
echo bitrate:$bitrate

#~re-create directory structure
find "$sourceDir" -type d -not -path "*$destDir*" -exec bash -c 'destPath="$2/${1#*"$3"}"; echo "item:$destPath"; mkdir -p "$destPath"' - {} "$destDir" "$sourceDir" \;

#~encode files
find "$sourceDir" -type f -not -path "*$destDir*" -exec bash -c 'destPath="$2/${1#*"$3"}"; echo "item:$destPath"; [[ "$1" == *".mp3" ]] && cp "$1" "$destPath" || ffmpeg -v quiet -stats -i "$1" -ab "$4" -map_metadata 0 -id3v2_version 3 "${destPath%.*}.mp3"' - {} "$destDir" "$sourceDir" "$bitrate" \;
echo Done.
