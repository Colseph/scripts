## Scripts
_various scripts to accomidate my lazyness_

### THE\_ARCHIVE
_a sad little place for stale, broken scripts that have no where else to go_
keeping for documentation/reference purposes


#### [pixivPool.sh](https://github.com/Colseph/scripts/blob/master/archive/pixivPool.sh)
   * used alongside [PixivUtil2](https://github.com/Nandaka/PixivUtil2 "PixivUtil2"). iterates recursively through directory1,
     then checks if hardlink exists in directory2, if not it is created.
     this way i can keep pics organized, and also have a big image pool for plex(not endless folders)
     <br>_realized theres a better way to do it w/ something like stow, and moved to [gallery-dl](https://github.com/mikf/gallery-dl) so no longer relevant_

#### [opt.sh](https://github.com/Colseph/scripts/blob/master/archive/opt.sh)
   * used on plex serv to move optimized versions to rclone mount and trigger manual plex scans.
   
#### [migrate.sh](https://github.com/Colseph/scripts/blob/master/archive/migrate.sh)
   * used on plex serv along with opt.sh.
     <br>triggered by \*arr programs(sonarr/radarr lidarr etc..). pauses rtorrent,
     <br>creates fast-resume torrent file, then moves files to rclone mount and
     <br>re-adds/moves and resumes torrent
     <br>in theory would allow to seed from cloud drive, but fails miserably
     <br>does use some pretty fancy hash tables/associative arrays, so thats cool...
     
#### [mkvMux.sh](https://github.com/Colseph/scripts/blob/master/archive/mkvMux.sh)
   * Script for tagging and remuxing **your** mkv files for **your library**
     <br>uses mkvtoolsnix, has option for remux or just propedit
   
#### [newsboat2flym.sh](https://github.com/Colseph/scripts/blob/master/archive/newsboat2flym.sh)
   * converts newsboat urls file to opml
     <br>**while preserving categories/tags**(same format flym uses)
     <br>uses newsboats built-in `--export-to-opml` to get `<outline/>` opml tags with url/title info
     <br>then parses the newsboat tags from newsboat `urls` file.
     <br>the script works by iterating over newsboat tags, thus everything without a tag will be assigned one.
     <br>the default category for untagged feeds is 'Unsorted'. can be changed in config section of script.
     <br>since idiots exist- this script uses `eval` to get newsboat tags while respecting quoted/spaced tags
     <br>(_yeah there might be a better way to do it, but idk what it is. if you figure it out feel free to do a PR._)
     <br>so.. dont name your tags stupid things like `);rm -rf /* #`

#### [time.sh](https://github.com/Colseph/scripts/blob/master/archive/time.sh)
   * does math with timestamps (+,-)(you can _try_ multiplication/division, but its not really possible w/ time
     <br>can also do logic -- ie. 12:00:00 > 00:1000:00 will return false
     <br>cant do carrot/exponential stuff(^)
     <br><br>The attempted multiplication/division work by converting to seconds.nanoseconds to do the math,
     <br>(tries to use hours as base unit).
     <br>then back to HH:MM:SS.nnnnnnnnnn
     <br>idk its just a concept
     <br>orininally made so someday i could change [delinker](https://github.com/Colseph/Delinker) to just bash,
     <br>but i got a little carried away.. lol

#### [nhentai.sh](https://github.com/Colseph/scripts/blob/master/archive/nhentai.sh)
   * downloads all nhentai favorites using gallery-dl
     <br>idk why its not included in gallery-dl(probs because of auth)
     <br>uses w3m, you login and it saves your cookie in `~/.w3m/cookie` with all your other cookies.
     <br>obv depends on `w3m` and `gallery-dl`. check to config section to setup gallery-dl command.
     <br>broken since nhentai added captcha and changed to dynamic stuff..

#### [qute-pass-wrapper](https://github.com/Colseph/scripts/blob/master/archive/qute-pass-wrapper)
   * wrapper for qute-pass plugin for qutebrowser. allows storing url inside the encrypted file
     <br>instead of in the file name/path
     <br>uses pass grep to find the entry, then passes it along with other arguments to qute-pass

#### [gateKeeper.sh](https://github.com/Colseph/scripts/blob/master/archive/gateKeeper.sh)
   * uses vnstat and xmlrpc to limit rtorrent to set data limit per month etc..
   <br>the idea was to allow the max speed for the remaining data/time
   <br>ie. remaining data / time left
