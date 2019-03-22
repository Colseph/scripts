_should be a gist or something, but wanted it here so its w/ my other scripts.._
# Crontab

## archiving multiple links w/ tools like youtube-dl/gallery-dl

_instead of having a cronjob for each channel/artist/gallery - one line in crontab that reads textfile w/ links_

_easier to add a link to a text file than create a new cronjob_

**change paths accordingly**


### gallery-dl

_iterates over lines in_`~/.config/gallery-dl/gallery-dl.txt`_, only processes lines w/_ `link:` _at beginning_
<br>_im not going to go into detail about configs. for that, see wiki [here](https://github.com/mikf/gallery-dl/tree/master/docs)_

#### crontab:

```
while read LINE; do [ "${LINE\%\%:*}" == "link" ] && gallery-dl --ignore-config -c /home/user/.config/gallery-dl/sfw.json "${LINE#*:}"; done < ~/.config/gallery-dl/gallery-dl.txt
```

#### textfile`gallery-dl.txt`:

_comment/artistname_

`this line will be treated as a comment`
<br>`link:[insert link here]`


### youtube-dl

_more advanced than one for gallery-dl as it accepts flags in textfile_
<br>_iterates over_ `~/.config/youtube-dl/youtube-dl.txt`_, only processes lines containing_ `link=(`

~~**as of now, spaces dont work for flags passed in the textfile**~~
<br>spaces **do** work now you just need to quote them, see example.

you could just have a set of flags/urls on each line without the whole 'if' statement
<br>but this way i can put comments and idk how it would handle spaces the other way
<br>if you quote an array w/ the '@' bash is smart enough to properly quote each argument(or treat each like its quoted.)

#### crontab:

_youtube-dl command w/ general flags you want for all videos, for examaple:_

```
while read LINE; do if [[ "$LINE" == *"link=("* ]]; then eval $LINE; youtube-dl -i --download-archive ~/.config/youtube-dl/youtube-dl_archive.txt -f bestvideo+bestaudio --merge-output-format mkv --add-metadata --write-annotations --write-info-json --write-thumbnail --all-subs --embed-thumbnail --embed-subs -o /zpool/youtube/%(uploader)s/%(title)s-%(id)s.%(ext)s "${link[@]}"; fi; done < ~/.config/youtube-dl/youtube-dl.txt
```
_i just use a config file so my crontab looks like this:_
```
while read LINE; do if [[ "$LINE" == *"link=("* ]]; then eval $LINE; youtube-dl --ignore-config --config-location /home/user/.config/youtube-dl/config "${link[@]}"; fi; done < ~/.config/youtube-dl/youtube-dl.txt
```

#### textfile`youtube-dl.txt`:

_links and optional link specific flags(filter names etc..) in array format as that seemed to be the easiest way to keep link and flags associated_

_you can also override the default flags you set, as later flags have higher priority_

`this will be treated as a comment`
<br>`link=(--optional-flag-here --other-flag 'data for flag w/ space' 'https://link.here.com')`
<hr>
