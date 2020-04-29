## Scripts
_various scripts to accomidate my lazyness_


#### [pixivPool.sh](https://github.com/Colseph/scripts/blob/master/pixivPool.sh)
   * used alongside [PixivUtil2](https://github.com/Nandaka/PixivUtil2 "PixivUtil2"). iterates recursively through directory1,
     then checks if hardlink exists in directory2, if not it is created.
     this way i can keep pics organized, and also have a big image pool for plex(not endless folders)
     <br>_honestly theres probs a better way to do it w/ something like stow_
     <br>**stale**

#### [opt.sh](https://github.com/Colseph/scripts/blob/master/opt.sh)
   * todo
     <br>**stale**
   
#### [migrate.sh](https://github.com/Colseph/scripts/blob/master/migrate.sh)
   * todo
     <br>**stale**
     
#### [mkvMux.sh](https://github.com/Colseph/scripts/blob/master/mkvMux.sh)
   * Script for tagging and remuxing **your** mkv files for **your library**
     <br>uses mkvtoolsnix, has option for remux or just propedit
     <br>-InProgress
     <br>TODO - make it more userfriendly - and add ability to use config file for defaults?
   
#### [lib2mp3.sh](https://github.com/Colseph/scripts/blob/master/lib2mp3.sh)
   * creates an mp3 version of flac/alac/whatever music library.
     <br>**while preserving the folder structure**
     <br>had a massive script originally then realized the whole thing could be done in like 2 lines.
     <br>(its not 2 lines because parameters are nice etc..)

#### [newsboat2flym.sh](https://github.com/Colseph/scripts/blob/master/newsboat2flym.sh)
   * converts newsboat urls file to opml
     <br>**while preserving categories/tags**(same format flym uses)
     <br>uses newsboats built-in `--export-to-opml` to get `<outline/>` opml tags with url/title info
     <br>then parses the newsboat tags from newsboat `urls` file.
     <br>the script works by iterating over newsboat tags, thus everything without a tag will be assigned one.
     <br>the default category for untagged feeds is 'Unsorted'. can be changed in config section of script.
     <br>since idiots exist- this script uses `eval` to get newsboat tags while respecting quoted/spaced tags
     <br>(_yeah there might be a better way to do it, but idk what it is. if you figure it out feel free to do a PR._)
     <br>so.. dont name your tags stupid things like `);rm -rf /* #`

#### [fbmp](https://github.com/Colseph/scripts/blob/master/fbmp)
   * mplayer in framebuffer (auto fit to tmux pane)(only tested with yaft)
     <br>specifically for use with tmux. originally made so i wouldnt have to manually type out
     <br>geometry commands etc.. but added auto sizing to match tmux pane.
     <br>assumes font chars are 8 pix wide, 16 tall, if things dont line up youll have to change it.
     <br>as of now, it just matches width and height to tmux pane, eventually ill probably work it
     <br>to keep the aspect ratio.

#### [time.sh](https://github.com/Colseph/scripts/blob/master/time.sh)
   * does math with timestamps (+,-)(you can _try_ multiplication/division, but its not really possible w/ time
     <br>can also do logic -- ie. 12:00:00 > 00:1000:00 will return false
     <br>cant do carrot/exponential stuff(^)
     <br><br>The attempted multiplication/division work by converting to seconds.nanoseconds to do the math,
     <br>(tries to use hours as base unit).
     <br>then back to HH:MM:SS.nnnnnnnnnn
     <br>idk its just a concept
     <br>orininally made so someday i could change [delinker](https://github.com/Colseph/Delinker) to just bash,
     <br>but i got a little carried away.. lol

#### [timelapse.sh](https://github.com/Colseph/scripts/blob/master/timelapse.sh)
   * simple script for making desktop timelapse.
   <br>uses scrot to take screenshot every n seconds
   <br>when user kills script w/ crtl-c it will ask if you want to create mp4 from frames.
   <br>has optional flags and defaults

#### [nhentai.sh](https://github.com/Colseph/scripts/blob/master/nhentai.sh)
   * downloads all nhentai favorites using gallery-dl
   <br>idk why its not included in gallery-dl(probs because of auth)
   <br>uses w3m, you login and it saves your cookie in `~/.w3m/cookie` with all your other cookies.
   <br>obv depends on `w3m` and `gallery-dl`. check to config section to setup gallery-dl command.

#### [qute-pass-wrapper](https://github.com/Colseph/scripts/blob/master/qute-pass-wrapper)
   * wrapper for qute-pass plugin for qutebrowser. allows storing url inside the encrypted file
   <br>instead of in the file name/path
   <br>uses pass grep to find the entry, then passes it along with other arguments to qute-pass

#### [crontab.md](https://github.com/Colseph/scripts/blob/master/crontab.md)

#### [Termux](https://github.com/Colseph/scripts/tree/master/termux)
   * termux scripts

#### [Japanese](https://github.com/Colseph/scripts/tree/master/japanese)
   * japanese stuff

#### [gateKeeper.sh](https://github.com/Colseph/scripts/blob/master/gateKeeper.sh)
_bash script that throttles/kills network traffic based on amount used, and time left until data-cap reset_
   * semi-incomplete atm, just geting base ideas down on "virtual paper" so to speak

**Dependencies**
   * vnstat

**Todo**
   * pause all torrents when limit reached
