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


'

#~mux
ffmpeg -i $i -c copy "${ffmpeg_args[@]}" "${attachments[@]}" "$output_dir/$i"
