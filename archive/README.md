## Scripts
_various scripts to accomidate my lazyness_

### THE\_ARCHIVE
_a sad little place for stale, broken scripts that have no where else to go_
keeping for documentation/reference purposes


#### [pixivPool.sh][1]
   * used alongside [PixivUtil2][2]. iterates recursively through directory1,
     then checks if hardlink exists in directory2, if not it is created. this
     way i can keep pics organized, and also have a big image pool for plex(not
     endless folders) _realized theres a better way to do it w/ something like
     stow, and moved to [gallery-dl][3] so no longer relevant_

#### [opt.sh][4]
   * used on plex serv to move optimized versions to rclone mount and trigger
     manual plex scans.
   
#### [migrate.sh][5]
   * used on plex serv along with opt.sh.
   * triggered by \*arr programs(sonarr/radarr lidarr etc..). pauses rtorrent,
     creates fast-resume torrent file, then moves files to rclone mount and
     re-adds/moves and resumes torrent in theory would allow to seed from cloud
     drive, but fails miserably. It does use some pretty fancy hash
     tables/associative tho arrays, so thats cool...
     
#### [mkvMux.sh][6]
   * Script for tagging and remuxing **your** mkv files for **your library**  
     uses mkvtoolsnix, has option for remux or just propedit
   
#### [newsboat2flym.sh][7]
   * converts newsboat urls file to opml **while preserving categories/tags**
     (same format flym uses). uses newsboats built-in `--export-to-opml` to get
     `<outline/>` opml tags with url/title info. then parses the newsboat tags
     from newsboat `urls` file.
   * the script works by iterating over newsboat tags, thus everything without
     a tag will be assigned one. the default category for untagged feeds is
     'Unsorted'. can be changed in config section of script.
   * since idiots exist- this script uses `eval` to get newsboat tags while
     respecting quoted/spaced tags (_yeah there might be a better way to do it,
     but idk what it is. if you figure it out feel free to do a PR._) so.. dont
     name your tags stupid things like `);rm -rf /* #`

#### [time.sh][8]
   * does math with timestamps (+,-)(you can _try_ multiplication/division, but
     its not really possible w/ time
   * can also do logic -- ie. 12:00:00 > 00:1000:00 will return false
   * cant do carrot/exponential stuff(^)
   * The attempted multiplication/division work by converting to
     seconds.nanoseconds to do the math, (tries to use hours as base unit).
     then back to HH:MM:SS.nnnnnnnnnn
   * idk its just a concept orininally made so someday i could change
     [delinker][9] to just bash, but i got a little carried away.. lol

#### [nhentai.sh][10]
   * downloads all nhentai favorites using gallery-dl
   * uses w3m, you login and it saves your cookie in `~/.w3m/cookie` with all
     your other cookies. obv depends on `w3m` and `gallery-dl`. check to config
     section to setup gallery-dl command.
   * broken since nhentai added captcha and changed to dynamic stuff..

#### [qute-pass-wrapper][11]
   * wrapper for qute-pass plugin for qutebrowser. allows storing url inside
     the encrypted file instead of in the file name/path. uses pass grep to
     find the entry, then passes it along with other arguments to qute-pass

#### [gateKeeper.sh][12]
   * uses vnstat and xmlrpc to limit rtorrent to set data limit per month etc..
     the idea was to allow the max speed for the remaining data/time
     (literally just does remaining data / time left)

[1]: /archive/pixivPool.sh
[2]: https://github.com/Nandaka/PixivUtil2 "PixivUtil2"
[3]: https://github.com/mikf/gallery-dl
[4]: /archive/opt.sh
[5]: /archive/migrate.sh
[6]: /archive/mkvMux.sh
[7]: /archive/newsboat2flym.sh
[8]: /archive/time.sh
[9]: https://github.com/Colseph/Delinker
[10]: /archive/nhentai.sh
[11]: https://github.com/Colseph/scripts/blob/master/archive/qute-pass-wrapper
[12]: https://github.com/Colseph/scripts/blob/master/archive/gateKeeper.sh
