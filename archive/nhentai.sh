#!/usr/bin/env bash

#~downloads nhentai favorites with gallery-dl

#~CONFIG

GAL_DL="gallery-dl --ignore-config -c $HOME/.config/gallery-dl/nsfw.json" #~your gallery-dl command
DEPENDENCIES=(w3m gallery-dl)
trap _ctrl_c INT

#~FUNCTIONS
_ctrl_c() {
	#~so you dont have to ctrl-c all 1000+ gallery-dl commands
	printf '%s\n' "Quitting..."
	exit
}

_checkSetup() {
	#~check deps, files, and cookies
	printf '%s\n' "checking deps.."
	for i in ${DEPENDENCIES[@]}; do
		[ -x "$(which $i)" ] || { printf '%s\n' "ERROR missing dependency: '$i'"; exit 1; }
	done
	printf '%s\n' "Dependencies good."
	printf '%s\n' "checking login status.."
	w3m -cookie -dump_source "https://nhentai.net/favorites" | gunzip -f | grep 'Login' > /dev/null && _setupCookie
	_getUrls
}

_setupCookie() {
	#~sets up user cookie file with w3m
	printf '%s\n' "Cookie expired, or doesn't exist"
	printf '%s\n' "Please login. Then press 'q' to quit"
	sleep 2
	w3m -cookie "https://nhentai.net/login/"
}

_getUrls() {
	#~parses html to get urls
	#~getting total page numbers
	LINKS=""
	TOTAL_PAGES=$(w3m -cookie -dump_source "https://nhentai.net/favorites" | gunzip -f | grep 'class="last"' | grep -o '[0-9]*')
	for ((i = 1; i <= TOTAL_PAGES; i++)); do
		printf '%s\n' "Getting favorites page $i of $TOTAL_PAGES:"
		printf '%s\n' "https://nhentai.net/favorites?page=$i"
		LINKS+=$(printf '\n%s' "$(w3m -cookie -dump_source "https://nhentai.net/favorites?page=$i" | gunzip -f | grep -o '/g/[0-9]*/')")
	done
	_download
}

_download() {
	#~downloads links using gallery-dl command
	for i in $LINKS; do
		$GAL_DL "https://nhentai.net$i"
	done
}

#~START SCRIPT
_checkSetup
