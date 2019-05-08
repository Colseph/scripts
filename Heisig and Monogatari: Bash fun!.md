## some kanji+bash fun
 - inspired by [this](https://hackernoon.com/learning-languages-very-quickly-with-the-help-of-some-very-basic-data-science-cdbf95288333) post.

### what we have:
 - vol 1-18 of the Monogatari Series(plus some extras) in text files
 - a [list](https://www.reddit.com/r/LearnJapanese/comments/1a126a/all_2200_kanji_from_heisigs_remembering_the_kanji/) of kanji, covered in Heisig's 6th ed Remembering the Kanji 1
	
### question(s):
 - what percentage of kanji in the Monogatari Series can be found in Heisig's book?
 <br>aka. how many kanji will you recognize if you complete remembering the kanji?
 <br>(obv actually learning the meanings/words containing said kanji is a whole different matter)
	
### the plan:
 1. create list of all kanji in the Monogatari Series along with the number of occurrences
 2. create list of rtk kanji
 3. compare the two, count occurrences of rtk kanji in the Monogatari Series, and get our percentage.
<hr>

	
OK, so we have our Monogatari Series txtfiles. first thing we want to do is get a collective list of all kanji and occurrences.
```
kuchinawa@nadeko ~/s/k/w/monogatari [0]
$ls
'01_化物語(上).txt'*    14_暦物語.txt*
'02_化物語(下).txt'*    15_終物語（上）.txt*
 03_傷物語.txt*         16_終物語（中）.txt*
'04_偽物語(上).txt'*    17_終物語（下）.txt*
'05_偽物語(下).txt'*    18_続・終物語.txt*
'06_猫物語(黒).txt'*    ひたぎスローイング.txt*
 07_猫物語（白）.txt*   ブラック羽川の12猫座占い.txt*
 08_傾物語.txt*         まいごのかたつむり.txt*
 09_花物語.txt*         佰物語_シナリオブック.txt*
 10_囮物語.txt*         別冊少年マガジン掲載_◆読者への挑戦状◆.txt*
 11_鬼物語.txt*        '化物語アニメコンプリートガイドブック 書き下ろし短々編.txt'*
 12_恋物語.txt*         新聞広告全集（上）.txt*
 13_憑物語.txt*         新聞広告全集（下）.txt*
 ```
 
 
 
we can do this with a little while loop to read each character then we'll pipe it through some dandies to polish it up.
```
cat *.txt | while IFS= read -r -n1 char; do echo $char; done | sort | uniq -c > "kanji_list"
```



we didn't worry about sorting out spaces and sign/symbol characters etc.. as theres _sooo_ many in japanese its easier to just do it manually w/ vim.
<br>now we have a file named `kanji_list`. If we open it, we see something that looks like this:
```
 102814
     26 ﻿
 102678
    715 !
      2 "
      2 &
      7 '
      2 +
      8 ,
   2441 -
...
hidden to save space
...
    928 ワ
  50337 を
  59758 ん
   8565 ン
   -------------cut here-------------
      2 﨟
   7765 一
    197 丁
    271 七
```

you'll notice its sorted by the character, this is really nice as it means all the non kanji stuff is at the top.
<br>now we just cut the top off the file and we have our list of kanji. lets see how many we've got:
```
kuchinawa@nadeko ~/s/k/w/monogatari [0]
$cat kanji_list | wc -l #~total unique kanji in Monogatari Series novels
2947

kuchinawa@nadeko ~/s/k/w/monogatari [0]
$total_kanji=0; while read LINE; do ((total_kanji+=${LINE% *})); done < kanji_list; echo $total_kanji #~total number of kanji characters in novels
877196
```



ok now we just need our Heisig list.
<br>I just grabbed the one from [this reddit post](https://www.reddit.com/r/LearnJapanese/comments/1a126a/all_2200_kanji_from_heisigs_remembering_the_kanji/) and pasted it in a file, and I got this:
```
一 二 三 四 五 六 七 八 九 十 口 日 月 田 目 古 吾 冒 朋 明 唱 晶 品 呂 昌 早 旭...
```

all on one line, seperated by spaces- perfect _for_ a for loop.

now we just iterate over every kanji in Heisig's list, find the corrisponding kanji in our monogatari list(if it exists) and add all the numbers. this will give us the total number of kanji characters in the Monogatari Series that are also in Hesigs list.
<br>(theres probably a cleaner way to do this)
```
kuchinawa@nadeko ~/s/k/w/monogatari [0]
$kanji_list=$(cat kanji_list) #~reads kanji_list to memory so we're not waiting for my painfully slow HDD I/O for each 'grep'

kuchinawa@nadeko ~/s/k/w/monogatari [0]
$for i in $(cat heisig_list); do kanji=$(printf "$kanji_list" | grep "$i") && ((hesig_kanji+=${kanji% *})); done; echo $hesig_kanji
855631
```



ok, now that we have our numbers, we can devide and get our percentage
```
kuchinawa@nadeko ~/s/k/w/monogatari [0]
$echo "(855631/877196)*100" | bc -l
97.54159845690130825900
```


so there's your answer. if you complete the James Heisig's Remembering the Kanji 1 (6th ed):
<br>you will recognize(and should know the stroke order) of **97%** of the kanji in the Monogatari Series light novels.
