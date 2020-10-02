## Scripts
_various scripts to accomidate my lazyness_


#### [lib2mp3.sh][1]
   * creates an mp3 version of flac/alac/whatever music library.
     **while preserving the folder structure**
   * had a massive script originally then realized the whole thing could be
     done in like 2 lines. (its not 2 lines because parameters are nice etc..)

#### [fbmp][2]
   * mplayer in framebuffer (auto fit to tmux pane)(only tested with yaft)
   * originally made so i wouldnt have to manually type out geometry commands
     etc.. but added auto sizing to match tmux pane. assumes font chars are 8
     pix wide, 16 tall, if things dont line up youll have to change it. as of
     now, it just matches width and height to tmux pane, eventually ill
     probably work it to keep the aspect ratio.

#### [timelapse.sh][3]
   * simple script for making desktop timelapse.
   * uses scrot to take screenshot every n seconds, when user kills script w/
     crtl-c it will ask if you want to create mp4 from frames.
   * has optional flags and defaults

#### [crontab.md][4]

#### [Termux][5]
   * termux scripts

#### [Japanese][6]
   * japanese stuff

#### [Archive][7]
   * old broken scripts I no longer use/update etc... kept for
     reference(without needing to go back in time to some old commit)

[1]: /lib2mp3.sh
[2]: /fbmp
[3]: /timelapse.sh
[4]: /crontab.md
[5]: /termux
[6]: /japanese
[7]: /archive
