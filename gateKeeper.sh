#!/usr/bin/env bash
:'just going to work on what i need when i need it
rn just need to reliably stop rtorrent from sucking up all my data
so just gonna work on that, ill leave the other stuff in here for future expansion
timeline?:
rtorrent throttling
whatever else if i feel like it
'

:'will eventually work with rtorrent and ufw
will have options for throttling rtorrent
and blocking all external traffic(anythong not 192.168.1/24? or whatever your lan is set to)
via ufw

itll calculate how much data youve used, and the max throughput you can have to stay in that limit
eg, uses vnstat, if day is after cutoff calculate for next month, if date is before, calculate
for last month. gets total used then estimates, and throttles accordingly
on per device(obviously) so set aside a specific amount for device and this thould stop it from
going over. lol idk well see(also if you have a vpn, use its interface(probs tun0 or something) to only
count external traffic/ ignore lan traffic
keep in mind, your computer may not always use all the data you set aside for it
and depending on how often this is run, if it doesnt run often enough, it could go over(see below in config)
'

#~TODO cutsomizableand dynamic
#~TODO conky integration?
#~if using conky yes in config, then it will echo/pring, or outputto log
#~conky=(yes|no)
#~conkyLog=(print|log) maybe have seperate pring and echo options?
#~vnstat -d -i tun0 -b "2018-10-19" -e "2018-11-04" | awk "/sum/ {print $10 " " $11}"

#~does math with IEC Prefix Base2 (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) because thats what i get from vnstat
#~^失礼、噛みました。 
#~if your using conky, you can change the display format/prefix in config section

#~~~~~~~~~~~~#
#~  Config  ~#
#~~~~~~~~~~~~#

:'The Max Amount of data you want this machine to use, can be base2(TiB) or base10(TB)
most people should be fine with base10 as thats more familiar and is probs what your ISP is using
if your torrenting etc/ you might want base2 idk whatever floats your boat
MUST have a space or parsing will fail(i could use awk etc to make it idiot proof but idk.. too lazy..)
'
#~accepts[string]:"Number[SPACE]Unit"
dataCap="1 TB" 

:'how often does your data cap reset?
reset type day(daily), week(weekly), month(monthly), year(yearly)
'
#~accepts[string]: "day"|"week"|"month"|"year"
resetType="month"

:'When does your datacap reset?
only uses the options if they fit inside the reset type specified above eg. monthly only uses resetDay and resetTime
'
#~accepts[int]: MM
resetMonth=12

:'if your doing weekly, set day as (0..6) where 0 is sunday
if your doing monthly the day must be 2 digits eg. 03
'
#~accepts[int]: DD|D
resetDay=19
#~accepts[string]: "HH:MM:SS"
resetTime="00:00:00"

:'What are you using this for?
All Traffic or just rotrrent?(or other program if you want to edit script to support it(ill try to make it easy))
uses TODO insert program here for throttling all traffic, uses program API to throttle program(rtorrent)
uses ufw to kill all traffic
'
#~TODO add custom option
#~user adds api command etc
#~and section for math(if program doesnt use KiB
#~accepts[string]: "all"|"rtorrent"
runType="rtorrent"

:'how do you want to control your traffic
throttle traffic: sets max throughput to last you to end of date
you will be throttled to (usableData / timeLeft)
kill traffic: no throttle, just runs a check, if data used is greater than or equal datacap, kill all traffic via UFW
FOR BOTH OPTIONS
deff recommended to put your datacap under what it actually is, as its likely some data will leak out between checks.
if your not using the the max throughput the throttle is giving you, the throttle will lessen as you near the end date
so if you dont use any of your, lets say 1TB of data until 1 day before reset
(usableData / timeLeft) - your throttle would be at 11.5MB/s(11MiB/s) and if your running this script every 5 min
its possible youd go 17GB over(16GiB) 
heres an equation to find how much you should under-shoot your dataCap
youll need to convert Mbps etc.. or whatever eg 1TB = 8000000Mb, 5min = 300Secs etc..
what you should put in the script = actualDataCap - (yourInternetSpeed * scriptRunInterval)
eg. if i have 1TB dataCap with 30mbps speed and i run this script every 5min: 1TB - (30mbps * 5min) = 998.875 GB
once you get over the 1Gbs speed range(if you somehow still have a cap RIP) your probs gonna be calculating for your
ethernet controller etc and if you have 10Gbit LAN... you should be smarter then me in this aspect.. good luck
BUT
if you dont want to do the equation just put calculateBuffer="yes", and your speed
(1 Gbps is what most ethernet controllers are btw)
and ill calculate it for you....(but if im the one calculating there will be a minimum of 5 GB Under actual dataCap)
(yes i know i could get rid of the wall of explaination above but i put time into
making that crappy explaination and it has sentimental value... (not really but idk, i dont wanna put it to waste..)
'
#~accepts[string]: "throttle"|"kill"
dataControl="throttle"
#~options[string]: "yes"|"no"
calculateBuffer="yes"
#~options[string]: "Number[SPACE]Unit"
iNetSpeed="14 Mbps"

:'interface to monitor (as of now theres only one interface, might add support for more in future?)
if your using a vpn, and only want to throttle external traffic(allow lan traffic) you could monitor tun interface etc
'
#~accepts[string]: "yourinterfacehere"
iFace="tun0"

:'Are you going to be runing this from conky?
'
#~accepts[string]: "yes"|"no"
conky="no"


#~~~~~~~~~~~~~~~#
#~  Functions  ~#
#~~~~~~~~~~~~~~~#


_createCalculations() {
	#~parses data above, and creates the functions needed for this particular setup
	#~optionally creates config to store created equations
	#~in my mind this will save some overhead, but idk if it might actually take more
	#~taxing to read the config instead of doing the calculations all over again...
	#~if reading the config is slower for your computer just turn config off above
}

_convertBytes() {
	#~converts formats MB MiB Mb etc..
	#~really easy cause when calling a function, bash treats each word in a string as an arg
	#~accepts strings in (N F) where N is one or more numbers and FF is the format in MB, GB, TB etc...	
	#~converts to KiB(most people with datacaps have less than 2.7ish TB(2.5ish TiB) a month(which is minimum for 1MiB/s)
	case $2 in
		b*)
			#~bits, only an insane person would use this
			outData=$(echo "$1 / 8192" | bc -l)
			;;	
		B*)
			outData=$(echo "$1 / 1024" | bc -l)
			;;
		Kb*)
			#~kilobit & /s
			outData=$(echo "$1 / 8.192" | bc -l)
			;;
		Kib*)
			#~Kibibit & /s
			outData=$(echo "$1 / 8" | bc -l)
			;;
		KB*)
			#~KiloByte
			outData=$(echo "$1 / 1.024" | bc -l)
			;;
		KiB*)
			#~KibiByte no change
			outData=$1
			;;
		Mb*)
			#~Megabit & /s
			outData=$(echo "$1 * 0.008192" | bc -l)
			;;
		Mib*)
			#~Mibibit
			outData=$(echo "$1 * 0.0078125" | bc -l)
			;;
		MB*)
			#~MegaBytes
			outData=$(echo "$1 * 0.001024" | bc -l)
			;;
		MiB*)
			#~MebiByte
			outData=$(echo "$1 * 0.0009765625" | bc -l)
			;;
		Gb*)
			#~Gigabit & /s
			outData=$(echo "$1 * 0.000008192" | bc -l)
			;;
		Gib*)
			#~Gibibit
			outData=$(echo "$1 * 0.000007629395" | bc -l)
			;;
		GB*)
			#~GigaByte
			outData=$(echo "$1 * 0.000001024" | bc -l)
			;;
		GiB*)
			#~GibiByte
			outData=$(echo "$1 * 0.0000009536743" | bc -l)
			;;
		Tb*)
			#~Terabit
			outData=$(echo "$1 * 0.000000008192" | bc -l)
			;;
		Tib*)
			#~Tebibit
			outData=$(echo "$1 * 0.000000007450581" | bc -l)
			;;
		TB*)
			#~TeraByte
			outData=$(echo "$1 * 0.000000001024" | bc -l)
			;;
		TiB*)
			#~TebiByte
			outData=$(echo "$1 * 0.0000000009313226" | bc -l)
			;;
		Pib*)
			#~Prbibit
			outData=$(echo "$1 * 0.000000000007275958" | bc -l)
			;;
		PB*)
			#~PetaByte
			outData=$(echo "$1 * 0.000000000001024" | bc -l)
			;;
		PiB*)
			#~PebiByte
			#~again back to the crazy people
			outData=$(echo "$1 * 0.0000000000009094947" | bc -l)
			;;
		*)
			#~catch
			echo "ERROR: could not match type '$2'"
			;;
	esac
	return $outData
}


#~~~~~~~~~~~~~~~~~~#
#~  Script Start  ~#
#~~~~~~~~~~~~~~~~~~#

#_calculate $resetType $resetTime $resetDay $resetMonth
#~lol justrealized how inconsistent my commenting format is here ... lol
#~use +1 $resetType - figure how make other dynamic? insteaf of greater than 19 do greater than resetType -1 (if was in an array?)
if [ `date +%d` -gtr 19 ]; then
	beginDate=`date +%Y-%m-19`
	endDate=$(date --date="`date +%Y-%m-19` +1 month" +%Y-%m-19)
else
	beginDate=$(date --date="`date +%Y-%m-19` -1 month" +%Y-%m-19)
	endDate=`date +%Y-%m-19`
fi

usedData=$(_convertBytes `vnstat -d -i tun0 -b "$beginDate" -e "$endDate" | awk '/sum of/ {print $10 " " $11}')
# if calculate buffer == yes dataCap=`_calculateBuffer $dataCap(convertBytes when done)`|| just convertBytes
# if used data is > cap _kill else
timeLeft=$((date --date="$endDate" +%s) - (date +%s))
rate=$(echo "($dataCap - $usedData) / ($timeLeft)" | bc -l)
#~should return KiB/s which is conveniently what rtorrent uses
#_if throttle == yes _throttle
#xmlrpc (really hoping i can get rtorrent to accept KiB... without supplying a hash)
#~end of script if data is greater than cap its killed, if its less than cap and throttle is enabled then itll
#~throttle(if throttle isnt enabled, then itll just kill when over cap like with throttle

