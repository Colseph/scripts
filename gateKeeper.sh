#!/usr/bin/env bash
#~will eventually work with rtorrent and ufw
#~will have options for throttling rtorrent
#~and blocking all external traffic(anythong not 192.168.1/24? or whatever your lan is set to)
#~via ufw

#~itll calculate how much data youve used, and the max throughput you can have to stay in that limit
#~eg, uses vnstat, if day is after cutoff calculate for next month, if date is before, calculate
#~for last month. gets total used then estimates, and throttles accordingly
#~on per device(obviously) so set aside a specific amount for device and this thould stop it from
#~going over. lol idk we'll see(also if you have a vpn, use its interface(probs tun0) to only
#~count external traffic/ ignore lan traffic
#~keep in mind, your computer may not always use the max limit you set
#~and depending on how often this is run, it could go over


#~TODO support data suffixes(MB,GB etc..)
#~TODO cutsomizableand dynamic
#~TODO conky integration?
#~if using conky yes in config, then it will echo/pring, or outputto log
#~conky=(yes|no)
#~conkyLog=(print|log) maybe have seperate pring and echo options?
#~vnstat -d -i tun0 -b "2018-10-19" -e "2018-11-04" | awk '/sum/ {print $10 " " $11}'

#~does math with IEC Prefix Base2 because thats what i get from vnstat
#~if your using conky, you can change the display format/prefix in config section

#~~~~~~~~~~~~#
#~  Config  ~#
#~~~~~~~~~~~~#

#~basic options

#~The Max Amount of data you want this machine to use, can be base2(TiB) or base10(TB)
#~most people should be fine with base10 as thats more familiar and is probs what your ISP is using
#~if your torrenting etc/ you might want base2 idk whatever floats your boat
#~MUST have a space or parsing will fail(i could use awk etc to make it idiot proof but idk.. too lazy..)
#~accepts[string]:"Number[SPACE]Unit"
dataCap="1 TB" 

#~how often does your data cap reset?
#~reset type daily, weekly, monthly, yearly
#~accepts[string]: "daily"|"weekly"|"monthly"|"yearly"
resetType="monthly"

#~When does your datacap reset?
#~only uses the options if they fit inside the reset type specified above eg. monthly only uses resetDay and resetTime
#~accepts[int]: MM
resetMonth=12
#~if your doing weekly, set day as (0..6) where 0 is sunday
#~if your doing monthly the day must be 2 digits eg. 03
#~accepts[int]: DD|D
resetDay=19
#~accepts[string]: "HH:MM:SS"
resetTime="00:00:00"

#~What are you using this for?
#~All Traffic or just rotrrent?(or other program if you want to edit script to support it(ill try to make it easy))
#~uses TODO insert program here for throttling all traffic, uses program API to throttle program(rtorrent)
#~uses ufw to kill all traffic
#~accepts[string]: "all"|"rtorrent"
runType="all"

#~how do you want to control your traffic
#~throttle traffic: sets max throughput to last you to end of date
#~eg. if you have 1TB per month and it resets on the 19th, you will be throttled to ((dataCap - used) / time left)

#~The Max Amount of data you want this machine to use, can be base2(TiB) or base10(TB)
#~most people should be fine with base10 as thats more familiar and is probs what your ISP is using
#~if your torrenting etc/ you might want base2 idk whatever floats your boat
#~MUST have a space or parsing will fail(i could use awk etc to make it idiot proof but idk.. too lazy..)
#~accepts[string]:"Number[SPACE]Unit"
data="1 TB" 

#~interface to monitor (as of now theres only one interface, might add support for more in future?)
#~if your using a vpn, and only want to throttle external traffic(allow lan traffic) you could monitor tun interface etc
#~accepts[string]: "yourinterfacehere"
interface="tun0"

#~Are you going to be runing this from conky?
#~options[string]: "yes"|"no"
conky="no"

#~Are you using this to control rtorrent traffic?
rtorrent="no"
#~~~~~~~~~~~~~~~#
#~  Functions  ~#
#~~~~~~~~~~~~~~~#

_convertBytes() {
	#~converts formats GB MB etc..
	#~really easy cause when calling a function, bash treats each word in a string as an arg
	#~accepts strings in (N.. FF) where N is one or more numbers and FF is the format in MB, GB, TB etc...	
	#~converts to KiB(most people with datacaps have less than 2.7ish TB(2.5ish TiB) a month(which is minimum for 1MiB/s
	case $2 in
		B)
			#~Bytes, only and insane person would use this
			#~as this script will probs only be accurate to rough GB(unless you run at a constant loop..)
			outData=$(echo "$1 / 1024" | bc -l)
			;;
		KiB)
			#~KibiByte no change
			outData=$1
			;;
		KB)
			#~KiloByte
			outData=$(echo "$1 / 1.024" | bc -l)
			;;
		MiB)
			#~MebiByte
			outData=$(echo "$1 * 0.0009765625" | bc -l)
			;;
		MB)
			#~MegaBytes
			outData=$(echo "$1 * 0.001024" | bc -l)
			;;
		GiB)
			#~GibiByte
			outData=$(echo "$1 * 0.0000009536743" | bc -l)
			;;
		GB)
			#~GigaByte
			outData=$(echo "$1 * 0.000001024" | bc -l)
			;;
		TiB)
			#~TebiByte
			outData=$(echo "$1 * 0.0000000009313226" | bc -l)
			;;
		TB)
			#~TeraByte
			outData=$(echo "$1 * 0.000000001024" | bc -l)
			;;
		PiB)
			#~PebiByte
			#~again back to the crazy people
			outData=$(echo "$1 * 0.0000000000009094947" | bc -l)
			;;
		PB)
			#~PetaByte
			outData=$(echo "$1 * 0.000000000001024" | bc -l)
			;;
		*)
			#~catch
			echo "ERROR: could not match type '$2'"
			;;
	esac
