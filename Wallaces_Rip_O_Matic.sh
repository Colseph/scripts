#~remake of mkvmux.sh using ffmpeg
#~reasoning:
#~1.ffmpeg is more of an 'all in one' solution (muxing and encoding)
#~2.(the real reason) one syntax(*cough cough* mkvpropedit im looking at you)
#~one minor setback is you wont be able to edit metadata w/o creating a new file
#~but in my book thats not a big deal as ill be muxing almost everytime i change metadata

#~Version: V0.01 (Wallace)

#~version notes
#~V0.01 (Wallace) -- initial commit, base idea/structure written out

: '
----------------
# ffmpeg notes #
----------------
will have it walk user through
(identifying tracks(lang etc) suggesting order etc...)
later add cli flags
-(i)nput_drectory
-(o)output_directory
-(e)ncode|(m)ux
-(a)rguments(user will just put all the ffmpeg args here)
if ffmpeg arguments are provided the script wont walk through anything
    otherise it will skip provided args(i o e/m) and ask for ffmpeg args(map etc)
(maybe add single use flags: extract subs/font_attachments etc..)
add file naming(ask user for title of show,and verify track info)
output with name,
when done, run crc? and add to end of filename(do when encoding too)
(extract SxxExx from filename)
add logging(with error codes etc..)

-c copy =mux
-map 0:v:0 =fileID:videotracks:videotrackID
(v=video/thumbnail/coverart_etc.. V=videoOnly a=audio s=subtitle d=data t=attachments)
-map 0:s =all subtitles etc..
-map -0:s =negative mapping to exclude
-metadata:s:v:0 "title="[LXR]" -metadata:s:v:0 language=eng
(the "s" is stream(out of the output streams(comes after -maps)))
-attach font.ttf -metadata:s:2 mimetype=application/x-truetype-font
(assuming the attachment will be third stream in output file)
(or) -attach font.ttf -metadata:s:t:0 mimetype=application/x-truetype-font
(for first attachment stream)
-disposition:s:0 default -disposition:s:0 forced
for track flags (the "s" in disposition is subtitles, not stream, so you can use Vvasdt etc..)


encoding defaults:
(will probably be encoding from mkv that already has fonts (look into how to include fonts))
-vf "subtitles=subs.ass" (or) -vf subtitles=input.mkv=si=0("si"=sub index? for first sub track) -map 0:v:0 -map 0:a:0
(the order of map determines the order of tracks in output)
get order from what standard is, so if its yours, you dont need to change anything
convert audio to 320K? idk look into see if can keep channels
use +faststart (web optimize)
default make 720 if res is above, else if src res is below assume dvd?
(ask user if want to keep src res or stretch?/crop if below 720p)
deinterlacing on dvd? most bluray is progressive, have script check w/ ffprobe?



'

#~~~~~~~~~~#
#~ Config ~#
#~~~~~~~~~~#
DEPENDENCIES=(ffmpeg ffprobe jq)

unset ATTACHMENTS
unset FFMPEG_ARGS
#~~~~~~~~~~~~~#
#~ Functions ~#
#~~~~~~~~~~~~~#

_help() {
    printf '%s\n' '
    usage:
    -h --help
        show this message
        specifying the following options will skip the
        corrisponding prompts in the script

    -r --run_type [e|m]
        (e)ncode or (m)ux

    -i --input_directory [directory]
        source directory for files to remux/encode
                   def: ./

    -o --output_directory [directory]
        destination directory for remuxed/encoded files
                   def: ./mkvMux_output

    ****ffmpeg arguments are static as of now, so if you
        specify an attachment, it will use it for EVERY file etc..
        so dont use these unless its only 1 file or you want every file to be the exact same
    ****ffmpeg arguments also need to be the last argument passed
    -a --arguments [ffmpeg args]
        arguments to pass to ffmpeg (remember to quote)
        example arg list:
        *remember, counting starts at 0*

        ----[global]----

            -map [fileID]:[streamType]:[TID]
                available streamTypes:
                    v=video/thumbnail/coverart,
                    V=videoOnly
                    a=audio
                    s=subtitle
                    d=data
                    t=attachments
                output order is same as the order
                the -map arg is used
                use negative fileID to exclude
                ex:
                    -map -0:s #~excludes all subs from first file


            -metadata:s:[streamType]:[TID] [identifier]="[value]"
                see -map for streamTypes
                (the s stands for stream)
                the TID is from the output not input
                example:
                    -map 0:v:0 -map 0:a:0 -map 1:a:0 -metadata:s:a:0 title="englishDub"
                    the output file will have 3 streams 1 vid and 2 audio
                    the metadata is for the first audio track in the output
                    which is the audio mapped from the first file


            -attach [attachment file] -metadata:s:[streamType]:[TID]
                the the -metadata arg is used to specify the attachment type
                the TID is from the output not input
                example:
                    -map 0:v:0 -map 0:a:0 -attach font.ttf -metadata:s:2 mimetype=application/x-truetype-font
                    the attachment is the third stream in output file
                    or
                    -map 0:v:0 -map 0:a:0 -attach font.ttf -metadata:s:t:0 mimetype=application/x-truetype-font
                    the attachment is the first attachment stream in the output file

                    
            -disposition:[streamType]:[TID] [value]
                used to set flags for tracks
                you can find all available values in ffmpeg documentation
                this script only uses:
                    default
                    forced

        ----[remux]----

            -c copy
                codec copy no encoding(same as source)

        ----[encode]----

            -vf subtitles=[subtitle file]
            or
            -vf subtitles=[mkv file]=si=[subtitle ID?]
            burns in subtitles from file or existing mkv file


        ----[ignore below]----

-map 0:v:0 =fileID:videotracks:videotrackID
-map 0:s =all subtitles etc..
-map -0:s =negative mapping to exclude
-metadata:s:v:0 "title="[LXR]" -metadata:s:v:0 language=eng
(the "s" is stream(out of the output streams(comes after -maps)))
-attach font.ttf -metadata:s:2 mimetype=application/x-truetype-font
(assuming the attachment will be third stream in output file)
(or) -attach font.ttf -metadata:s:t:0 mimetype=application/x-truetype-font
(for first attachment stream)
-disposition:s:0 default -disposition:s:0 forced
for track flags (the "s" in disposition is subtitles, not stream, so you can use Vvasdt etc..)


encoding defaults:
(will probably be encoding from mkv that already has fonts (look into how to include fonts))
-vf "subtitles=subs.ass" (or) -vf subtitles=input.mkv=si=0("si"=sub index? for first sub track) -map 0:v:0 -map 0:a:0

    '
}

_checkDeps() {
    for p in "${DEPENDENCIES[@]}"; do
        if ! [ -x "$(command -v $p)" ]; then
            printf '%s\n' "ERROR unable to find executable: $p"; exit 1;
        fi
    done
}

_checkPaths() {
    mkdir -p "$@"
}

_parseFileInfo() {
    #~gets file info(track names/types metadata/order etc..)
    FILE_INFO=$(ffprobe "$1")
}


#~~~~~~~~~~~~~~~~#
#~ Script Start ~#
#~~~~~~~~~~~~~~~~#

#~args
while [ "$1" != "" ]; do
    case $1 in
        *help)
            _help
            exit
           ;;
    -r*)
           shift
           RUN_TYPE="$1"
           ;;
       -i*)
           shift
           SOURCE_DIR="$1"
           ;;
       -o*)
           shift
           DEST_DIR="$1"
           ;;
       -a*)
           shift
           FFMPEG_ARGS=("$@")
           #~clear out the rest of the arguments as ffmpeg args should be last
           while [ "$1" != "" ]; do
               shift
           done
           ;;
    *)
        echo "unknown option: '$1'"
       _help
       exit 1
       ;;
    esac
    shift
done
#~mux

ffmpeg -i $i -c copy "${ffmpeg_args[@]}" "${attachments[@]}" "$output_dir/$i"
