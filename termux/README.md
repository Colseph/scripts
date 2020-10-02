## Termux
_The 'I can't believe its only a Terminal Emulator' Terminal Emulator_

### This folder will contain all my Termux scripts, widgets and gizmos
it will mostly consist of a `~/bin/termux-url-opener` and accompanying scripts.
local and remote.
<hr>

#### [termux-url-opener][1]
   * TODO(just idea)
   * wrapper script for various urls:
     - youtube
     - soundcloud
     - pixiv artist profiles
     - image galleries
     - etc.. etc..
   * anything from passing url to another script, to opening url on remote
     machine
    
#### [termux-to-scraper.sh][2]
   * TODO(just idea)
   * located on remote server. takes args from termux on phone via ssh. adds
     link to `gallery-dl`/`youtube-dl` textfile for scraping(if id doesnt
     already exist)
   * or maybe located locally on phone, and just used to craft command string
     to pass to server via ssh
   
#### [rsync.sh][3]
   * TODO(just idea)
   * rsync - copies files(maybe delete too?) from local folders to remote
     server(for pixiv/reddit saved pics/downloads etc..)

[1]: /termux/termux-url-opener
[2]: /termux/termux-to-scraper.sh
[3]: /termux/rsync.sh
