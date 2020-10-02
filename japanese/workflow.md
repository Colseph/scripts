## Japanese Study Workflow

_Using [MIA](https://massimmersionapproach.com/) as a guide, so this will be
listed out in stages._
 * Each stage will contain what I did/am doing in that stage.

<hr>

### Stage 01

#### Specifics

| Immersion Type    | Hours | Input Source           |
|:-----------------:|:-----:|:----------------------:|
| Passive Listening | 5+    | Anime Audio/podcasts   |
| Active Listening  | 1+-   | Anime/TV               |
| Active Reading    | 1+-   | Subs/VNs/Doujins/Manga |
| SRS               | 1+-   |                        |

_usually I get about 2+ Hrs total of Active Immersion whether its Listening,
Reading, or SRS_

#### Flow

* **Anime/TV shows**  
  I'll pick a show I want to watch, if I have the BD I'll use [MakeMKV][1] to
  get the mkv files on my computer, then I'll [lolify][2] the mkv's to save
  space and eliminate the extra tracks(if there are any). Next, depending on
  whether or not I want to focus on Reading or Listening I'll Download Japanese
  Subtitles from [kitsuneko][3] and watch the mp4's on my pc with [mpv][4]
  using `zZ` to adjust subtitle timing if needed.  As I find 1T sentences, I'll
  use `s` to take a screenshot, and later I'll find the line in the sub file
  ~~(hopefully I'll find a better way to do this)~~ going to be writing an mpv
  wrapper script of sorts that'll use IPC to get sub lines and timings etc..
  (maybe even extract audio and a frame for picture?)
  
* **VNs**  
  For Visual Novels, I'll use [ITH][5] to automatically copy the 1T sentences
  to a clipboard, then I can just paste straight into a text file for later
  use. I will also have [firefox][6] open to a blank html page with
  [autoscroll][7], and [yomichan][8] so I can quickly look up a word if its
  _really_ bugging me.

* **Doujins/Manga**  
  I'll Generally just read them on my phone, using [Tachiyomi][9]. I'll just
  screenshot 1T sentences, and add them to srs later.

* **Passive Listening**  
  Generally my Passive Listening is Anime audio. Once I've _finished_ a show(to
  avoid spoilers), I'll run [zombify][10] to get mp3's which I'll either throw
  on my phone or my Ipod. I'll keep an earbud in during most of the day at work
  and I'll generally keep it playing in the car on my way to and from. Since I
  have a lot more time for Passive Immersion than Active Immersion, I'll
  generally finish listening to the audio from the last series, before I've
  finished the series I'm currently watching. When this happens, I'll usually
  listen to podcasts, or random series I've watched a long time ago that I dont
  plan on watching again anytime sooon.

* **SRS**  
  For Kanji, I'm working through the [RRK deck][11] with [Anki][12]. I had 25
  new cards a day selected from a previous deck, and I've just left it. While
  going through new cards, I'll look through [the book][13] when theres new
  elements that weren't introduced. For Sentences, I grabbed the
  [Example Sentence Deck][14] because it has the groups setup already and I'm
  lazy. I removed any existing sentences that weren't already 1T, and have been
  adding my new sentences to it. Currently I try to add 10 or so new sentences
  per day.


<hr>

[1]: https://www.makemkv.com/
[2]: https://github.com/Colseph/scripts/blob/master/japanese/lolify
[3]: https://kitsunekko.net/
[4]: https://mpv.io/
[5]: https://code.google.com/archive/p/interactive-text-hooker/
[6]: https://www.mozilla.org/en-US/firefox/
[7]: https://addons.mozilla.org/en-US/firefox/addon/autoscrolling/
[8]: https://addons.mozilla.org/en-US/firefox/addon/yomichan/
[9]: https://tachiyomi.org/
[10]: https://github.com/Colseph/scripts/blob/master/japanese/zombify
[11]: https://www.mediafire.com/file/1svvsr7f9cnpwka/Recognition_RTK.apkg/
[12]: https://apps.ankiweb.net/
[13]: https://en.wikipedia.org/wiki/Remembering_the_Kanji_and_Remembering_the_Hanzi
[14]: https://www.mediafire.com/file/422gkvon0o7m5av/Example_Sentence_Cards.apkg
