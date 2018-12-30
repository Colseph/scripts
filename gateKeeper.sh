#!/usr/bin/env bash
: 'ok so i had this great idea..
it involves trashing almost everything and starting over in favor of
... in favor of... something.. hopefully great.
you can add custom functions in the functions.apps section
i already have one for rtorrent, ufw, and "text" display.
DONT use the actual name of the app, or the script will start the actual app
eg rtorrent=rtrnt ufw=ufwApp etc...


keeping this because pressing the wrong key in vim can be funny
and i need at least one ref to anime.
----------------------
#~does math with IEC Prefix Base2 (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) (specifically KibiBytes[KiB]) because thats what i get from vnstat
#~^失礼、噛みました。 
----------------------
this script really does work w/ KiB so if you want something different to be displayed /passed to and app you need to change it in your function
'

#~~~~~~~~~~~~#
#~  Config  ~#
#~~~~~~~~~~~~#
: 'The goal of this script is to be dynamic..
youll need vnstat for monitoring
this assumes you have it setup etc..
for rtorrent/ufw etc.. youll obv need them installed along with deps(xmlrpc-c for rtorrent etc..)



the syntax is as such:
params=([appToThrottle],[optional additional args]:[datalimit],[reset interva1: only supports month atm],[day of reset],[interfaceToMonitor]:[display app],[optional additional args])
'
#~example:params=("rtrnt:400 GB,month,19,tun0:text" "ufwApp,tun0:1 TB,month,19,tun0:text")
params=("rtrnt:400 GB,month,19,tun0:text")


: 'the buffer is to make it so you dont accidently go over your set datalimit
for example if the script only runs every 5 min and you are transfering at speed of 10MBps and your cap is 1TB, then if the script runs when your at 999GB
,by the time the script runs again, youd be 3GB over.(this is generally only
a problem for the "killall" type stuff like ufw/iptables firewalls
the things that use the rate (eg rtorrent) should always stay under the
maximum so they should be fine.
'
#if im calculating buffer then buffer will be min of 5 GB
calcBuffer="yes"
iNetSpeed="14 MBps"	#~case sensitive:: per second(only needed if calculating buffer)
runInterval="600"	#~how often is the script being run in seconds(only needed if calculating buffer

#~~~~~~~~~~~~~~~#
#~  Functions  ~#
#~~~~~~~~~~~~~~~#
_convertBytes() {
	#~converts formats MB MiB Mb etc..
	#~really easy cause when calling a function, bash treats each word in a string as an arg
	#~accepts strings in (N F) where N is one or more numbers and F is the format in MB, GB, TB etc...	
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
			outData=$(echo "$1 / 0.008192" | bc -l)
			;;
		Mib*)
			#~Mibibit
			outData=$(echo "$1 / 0.0078125" | bc -l)
			;;
		MB*)
			#~MegaBytes
			outData=$(echo "$1 / 0.001024" | bc -l)
			;;
		MiB*)
			#~MebiByte
			outData=$(echo "$1 / 0.0009765625" | bc -l)
			;;
		Gb*)
			#~Gigabit & /s
			outData=$(echo "$1 / 0.000008192" | bc -l)
			;;
		Gib*)
			#~Gibibit
			outData=$(echo "$1 / 0.000007629395" | bc -l)
			;;
		GB*)
			#~GigaByte
			outData=$(echo "$1 / 0.000001024" | bc -l)
			;;
		GiB*)
			#~GibiByte
			outData=$(echo "$1 / 0.0000009536743" | bc -l)
			;;
		Tb*)
			#~Terabit
			outData=$(echo "$1 / 0.000000008192" | bc -l)
			;;
		Tib*)
			#~Tebibit
			outData=$(echo "$1 / 0.000000007450581" | bc -l)
			;;
		TB*)
			#~TeraByte
			outData=$(echo "$1 / 0.000000001024" | bc -l)
			;;
		TiB*)
			#~TebiByte
			outData=$(echo "$1 / 0.0000000009313226" | bc -l)
			;;
		Pib*)
			#~Prbibit
			outData=$(echo "$1 / 0.000000000007275958" | bc -l)
			;;
		PB*)
			#~PetaByte
			outData=$(echo "$1 / 0.000000000001024" | bc -l)
			;;
		PiB*)
			#~PebiByte
			#~again back to the crazy people
			outData=$(echo "$1 / 0.0000000000009094947" | bc -l)
			;;
		*)
			#~catch
			echo "ERROR: could not match type '$2'"
			;;
	esac
	echo $outData
}

_splitArgs() {
	#~splits args at specified delimiter(then i dont need to mess w/ ifs in every function
	#returns split args in $argArray
	local IFS="$2"
	argArray=($1)
}

_calcBuffer() {
		iNetSpeedKiB=$(_convertBytes $iNetSpeed)
		buffer=$(echo "$iNetSpeedKiB * $runInterval" | bc -l)
		[ $(echo "$buffer > 4882813" | bc -l) == 0 ] && buffer=4882813
		totalData=$(echo "$totalData - $buffer" | bc -l)
}

_dates() {
	if [ "`date +%d`" -gt "$dateReset" ]; then
		beginDate=`date +%Y-%m-$dateReset`
		endDate=$(date --date="`date +%Y-%m-$dateReset` +1 $dateInterval" +%Y-%m-$dateReset)
	else
		beginDate=$(date --date="`date +%Y-%m-$dateReset` -1 $dateInterval" +%Y-%m-$dateReset)
		endDate=`date +%Y-%m-$dateReset`
	fi

	timeLeft=$(echo "(`date --date="$endDate" +%s`) - (`date +%s`)" | bc -l)
}

_maths() {
	_splitArgs "$@" ","
	#~get totalData/calculate buffer if asked
	totalData=$(_convertBytes ${argArray[0]})
	[ $calcBuffer == "yes" ] && _calcBuffer

	#~get dates
	dateInterval=${argArray[1]}
	dateReset=${argArray[2]}
	_dates

	#~get used data
	iFace=${argArray[3]}
	usedData=$(_convertBytes `vnstat -d -i $iFace -b "$beginDate" -e "$endDate" | awk '/sum of/ {print $10 " " $11}'`)

	#~takes all info and calcs rate (KiB/s)
	rate=$(echo "($totalData - $usedData) / ($timeLeft)" | bc -l)
}

#~~~~~~~~#
#~ apps ~#
#~~~~~~~~#
#~heres where you can add your custom apps / display apps
#~apps
rtrnt() {
	#~sends rate to rtorrent via rpc2
	local rpcPath="localhost:8080"
	#~make sure to split the rate(if you do total rate for both,
	#~and they both are totally saturated, youll be double the rate etc)
	#local uploadRate=$(echo "($rate / 3) * 2" | bc -l) #~2/3 of the total rate
	#local downloadRate=$(echo "($rate / 3)" | bc -l) #~1/3 of total rate
	local uploadRate=$(echo "$rate / 2" | bc -l) #~2/3 of the total rate
	local downloadRate=$(echo "$rate / 2" | bc -l) #~1/3 of total rate

	#~sets rates on rtorrent
	#~only uses whole? numbers (stips decimals)
	#xmlrpc $rpcPath throttle.global_up.max_rate.set_kb s/'' i/${uploadRate%%.*}
	xmlrpc $rpcPath throttle.global_up.max_rate.set_kb s/'' i/$(printf "%03.0f" "$uploadRate")
	#xmlrpc $rpcPath throttle.global_down.max_rate.set_kb s/'' i/${downloadRate%%.*}
	xmlrpc $rpcPath throttle.global_down.max_rate.set_kb s/'' i/$(printf "%03.0f" "$downloadRate")
}

ufwApp() {
	#~when limit reached, kills all traffic on provided interface
	echo not yet...
}

#~display apps
text() {
	#~outputs to text file(replaces existing info)
	#~this way i can have a nice formated text file, and this wont affect formatting
	local percentUsed=$(echo "($usedData / $totalData) * 20" | bc -l)
	local gbUsed=$(echo "$usedData * 0.000001024" | bc -l)
	local gbTotal=$(echo "$totalData * 0.000001024" | bc -l)
	echo "
	APP: $app
	-----------------
	Data: ${gbUsed%%.*}GB / ${gbTotal%%.*}GB -- $(printf "%05.2f" "$percentUsed")% used
	resetDate: $endDate
	time until reset: $timeLeft Seconds
	rate: ${rate%.*} KiB/s

	" > /share/nginx/html/gateKeeper.txt
}

for i in ${!params[@]}; do
	_splitArgs "${params[$i]}" ":"
	#~saves values so they wont be changed when other functions use _splitArgs
	mathsArgs="${argArray[1]}"
	app="${argArray[0]}"
	displayApp=${argArray[2]}
	_maths "$mathsArgs"
	#~calls function w/ same name as the first arg in the app/display sections
	${app%%,*} ${app#*,}
	${displayApp%%,*} ${displayApp#*,}
done
