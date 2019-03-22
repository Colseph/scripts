## Scripts
_various scripts to accomidate my lazyness_

## inProg branch:
I tend to work from lots of different computers.
<br>the branch is just a place for ideas and partial scripts.


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
   
#### [lib2mp3.sh](https://github.com/Colseph/scripts/blob/master/lib2mp3.sh)
   * creates an mp3 version of flac/alac/whatever music library.
     <br>**while preserving the folder structure**
     <br>had a massive script originally then realized the whole thing could be done in like 2 lines.
     <br>(its not 2 lines because parameters are nice etc..)

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

#### [crontab.md](https://github.com/Colseph/scripts/blob/master/crontab.md)
