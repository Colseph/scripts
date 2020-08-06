## Scripts
_various scripts to accomidate my lazyness_


#### [lib2mp3.sh](https://github.com/Colseph/scripts/blob/master/lib2mp3.sh)
   * creates an mp3 version of flac/alac/whatever music library.
     <br>**while preserving the folder structure**
     <br>had a massive script originally then realized the whole thing could be done in like 2 lines.
     <br>(its not 2 lines because parameters are nice etc..)

#### [fbmp](https://github.com/Colseph/scripts/blob/master/fbmp)
   * mplayer in framebuffer (auto fit to tmux pane)(only tested with yaft)
     <br>specifically for use with tmux. originally made so i wouldnt have to manually type out
     <br>geometry commands etc.. but added auto sizing to match tmux pane.
     <br>assumes font chars are 8 pix wide, 16 tall, if things dont line up youll have to change it.
     <br>as of now, it just matches width and height to tmux pane, eventually ill probably work it
     <br>to keep the aspect ratio.

#### [timelapse.sh](https://github.com/Colseph/scripts/blob/master/timelapse.sh)
   * simple script for making desktop timelapse.
   <br>uses scrot to take screenshot every n seconds
   <br>when user kills script w/ crtl-c it will ask if you want to create mp4 from frames.
   <br>has optional flags and defaults

#### [crontab.md](https://github.com/Colseph/scripts/blob/master/crontab.md)

#### [Termux](https://github.com/Colseph/scripts/tree/master/termux)
   * termux scripts

#### [Japanese](https://github.com/Colseph/scripts/tree/master/japanese)
   * japanese stuff

#### [Archive](https://github.com/Colseph/scripts/tree/master/archive)
   * old broken scripts I no longer use/update etc...
     <br>kept for reference(without needing to go back in time to some old commit)
