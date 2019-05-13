#!/usr/bin/env bash
#~MKV muxer/tagger
#~requires mkvtoolnix(might attempt ffmpeg ver later?)
#~Author - LuX/\er (LXR)
#~Version 0.1 (Victor)
#~Changelog -
#~v0.1(Victor) - Initial Write-up
#~TODO going to need to add function for parsing arguments for both mkvmerge and mkbpropedit
#~     one will be the standard and the other will have flags converted by script

#~~~~~~~~~~#
#~ Config ~#
#~~~~~~~~~~#
DEPENDENCIES=(mkvmerge mkvextract mkvpropedit mkvinfo)

unset CHAP_ARGS
unset SUB_ARGS
unset ATT_ARGS
unset TRACK_ORDER
unset EPISODE_ARGS
#~~~~~~~~~~~~~#
#~ Functions ~#
#~~~~~~~~~~~~~#

_help() {
    printf '%s\n' "
    usage:
    -h --help      show this message

    -rt [m|p]      runType - (m)erge or (p)roperty edit
                   merge involves BOTH remuxing and property edit
                   property edit, can only change metadata, but is much faster
                   when in prop edit mode: merge args will be ignored
                   def: m

    -s [directory] source directory for files to remux/tag
                   def: ./

    -d [directory] destination directory for remuxed/tagged files
                   def: ./mkvMux_output

    -e [extention] extension for the input files (output will be mkv)
                   def: mkv
    "
}

_checkDeps() {
    for p in "${DEPENDENCIES[@]}"; do
        if ! [ -x "$(command -v $p)" ]; then
            printf '%s\n' "$p is not installed or in the scripts PATH"; exit 1;
        fi
    done
}

_checkPaths() {
    mkdir -p "$@"
}

_extractChapters() {
    CHAP_ARGS="_insertArg chap"
    for a in "$(ls *.$EXT)"; do
        mkvextract "$a" chapters "$a.xml"
    done
    read -n 1 -p "Pausing for Chapter Edit(.xml). Press any key to continue..."
    clear
}

_insertArg() {
    #~acts as a nested variable of sorts
    case $1 in
        chap)
            printf '%s' "--chapters '$i.xml'"
            ;;
        *)
            printf '%s' "$i"
    esac
}

_remux() {
    printf '%s\n' 'Numbering starts at 0'
    printf '%s\n' '--default-track <TID[:bool]> --forced-track <TID[:bool]> --language TID:lang --track-name TID:"Name"'
    _getArgs merge
    [ -e "$i.[att].txt" ] && _attachments
    mkvmerge -o "$DEST_DIR/${i%.*}.mkv" "${EPISODE_ARGS_ARRAY[@]}" "$i" $SUB_ARGS $ATT_ARGS $TRACK_ORDER $($CHAP_ARGS)
}

_propEdit() {
    printf '%s\n' 'Numbering starts at 1'
    printf '%s\n' '--edit info --set "title=title here" --edit track:n --set "language=[lang]" --set "name=[name]"'
    printf '%s\n' '--edit track:n --set "flag-default=[bool]" --set "flag-forced=[bool]"'
    _getArgs propEdit
    mkvpropedit "$i" "${EPISODE_ARGS_ARRAY[@]}" $($CHAP_ARGS)
}

_attachments() {
    while read LINE; do
        set ATT_ARGS+=" --attach-file $LINE"
    done < $i[att].txt
}

_getArgs() {
    printf '%s\n' "Please Enter Episode Arguments"
    read -p ">> " EPISODE_ARGS_STRING
    #~convert string to array to allow spaced argument quoting
    STR_2_ARR="EPISODE_ARGS_ARRAY=($EPISODE_ARGS_STRING)"
    eval $STR_2_ARR
    if [ "$1" == "merge" ]; then
        printf '%s\n' "Please Enter Subtite Arguments"
        read -p ">> " SUB_ARGS
        printf '%s\n' "Please Enter Track Order"
        read -p ">> " TRACK_ORDER
    fi
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
       -s)
           shift
           SOURCE_DIR="$1"
           ;;
       -d)
           shift
           DEST_DIR="$1"
           ;;
    -rt)
           shift
           RUN_TYPE="$1"
           ;;
    -e)
       shift
       EXT="$1"
       ;;
    *)
        echo "unknown option: '$1'"
       _help
       exit 1
       ;;
    esac
    shift
done

#~defaults
SOURCE_DIR=${SOURCE_DIR:-./}
DEST_DIR=${DEST_DIR:-./mkvMux_output}
RUN_TYPE=${RUN_TYPE:-m}
EXT=${EXT:-mkv}
_checkDeps
_checkPaths $SOURCE_DIR $DEST_DIR

read -p "Would you like to Extract & Rename Chapters?[y/N]" EDIT_CHAPTERS
EDIT_CHAPTERS=${EDIT_CHAPTERS:-n}
[ ${EDIT_CHAPTERS,,} == "y" ] && _extractChapters
echo beforeloop

for i in "$(ls *.$EXT)"; do
    [ "${RUN_TYPE,,}" == "m" ] && _remux || _propEdit
done
