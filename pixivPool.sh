#!/usr/bin/env bash

#~TODO try -exec wc -l - {} \+ or something(get total number of files? then subtract wc -l that was printed?

#~~~~~~~~CONFIG~~~~~~~~#
#~you should be fine leaving this, unless you have file/foldernames with ':' in them that'll mess up the parsing
#~if you change this youll need to change the delimiter in the dir variable: dir=(targetDir1*destDir etc*etc)
delim=':'
#~directories to link
#~SYNTAX:dir=(targetPath1:DestinationPath1 targetPath1:DestinationPath2 etc:etc)   trailing '/' is optional
#~quote if the path has spaces(just to keep the target and destinations together)
#~Example:
#dir=('/i am a/path with/spaces':/IDontHave/Spaces "i have/spaces:i do/too" /i/dont:/me/either)
dir=(/zpool1/media/pics/pixiv:/zpool1/plex/libraries/pics/pixiv /zpool1/media/pics/pixiv:/home/user/wallpapers)
: '
Explaination of how the variable expansion and splitting works in the for loop
because its pretty intense and idk if ill remember it
first the for loop iterates the indicies of the array ${!array[@]} eg: 0 1 2 3 for an array with 4 items
it does this to keep the paths together when they have spaces in them
(for some reason the for loop treats an array of strings containing spaces as one giant string and uses the spaces as delims)
then it gets the value of the current index ${array[$i]} 
at the same time it splits the array based on the delimeter specified above
assuming ":" is the delimiter, it would normally would look like: ${string%:*} to get the smallest suffix(leaves us w/ first half)
and ${string#*:} to remove the smallest prefix(leaves us with the last half)
combined it lookes like ${array[$i]%:*} to get first and ${array[$i]#*:} to get last
if we add in the variable for the delim: its ${array[$i]#*$delim}
-changed method a little. now instead of printing to a variable then
evaluating the variable(might be a little higher on ram but still worked) i exec for each file found
spent like 5 hrs trying to figure why itd run fine on some files but not others(itd work fine on massive directories full of source code 
but itd fail on pixiv
it was because some files had a single quote in the name........
ugh. and it was hard to parse a single line of 3000+ if statements..
anyways, you can look back at commit "4133281" to see the original version
because its still pretty cool, just not as "nice" as the current version
'

for i in ${!dir[@]}; do

	#~only hardlinks if file does not exist with same name in target dir
	#~TODO doesnt work with dupes which is fine, but the number of files in the source dir and dest dont match even after subtracting the dirs and dupes...
	find "${dir[$i]%$delim*}" -name '*.*' -exec bash -c '[ -e "$2/${1##*/}" ] || ln "$1" "$2/"' - {} ${dir[$i]#*$delim} \;

done
