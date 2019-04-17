#!/usr/bin/env bash
#~timelapse script - reqs: ffmpeg, scrot, bash>=4.0

#~config
unset L_DIR L_DELAY L_OPT
trap _ctrl_c INT

#~functions
_ctrl_c() {
	printf '%s\n' "timelapse stopped."
	read -n 1 -p "Would you like to encode mp4 now?[Y/n]" L_OPT
	L_OPT=${L_OPT:-y}
	[ ${L_OPT,,} = "y" ] && _encodeLapse || exit
}

_encodeLapse() {
	printf '%s\n' "encoding at $L_FPS frames per second"
	ffmpeg -r $L_FPS -pix_fmt yuv420p -i "$L_DIR/%09d.png" -vcodec libx264 -crf 18 "$L_DIR/$L_NAME"
	exit
}

_help() {
	printf '%s\n' "
	options

	-h --help  print this message

	-o	   output file name

	-d	   directory for screenshots

	-s	   time to sleep between screenshots

	-f	   fps for finished video(if encoding)
	"
}

#~script start
while [ "$1" != "" ]; do
	case $1 in
		*-h*)
			_help
			exit
			;;

		*o)
			shift
			L_NAME="$1"
			;;
		*d)
			shift
			L_DIR="$1"
			;;
		*s)
			shift
			L_DELAY="$1"
			;;
		*f)
			shift
			L_FPS="$1"
			;;
		*)
			printf '%s\n' "unknown option '$1$'"
			_help
			exit 1
	esac
	shift
done
#~defaults
L_NAME=${L_NAME:-completed_timelapse.mp4}
L_DIR=${L_DIR:-./timelapse}
L_DELAY=${L_DELAY:-2}
L_FPS=${L_FPS:-30}
mkdir -p "$L_DIR"
FRAME=0
while true; do
	scrot "$L_DIR/$(printf '%09d' "$FRAME").png"
	((FRAME+=1))
	sleep $L_DELAY
done
