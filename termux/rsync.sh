#!/data/data/com.termux/files/usr/bin/env bash
#~uses rsync/with rrsync counterpart - copies phone files to server
#~so you'll need to do the whole command="/path/to/rrsync ..." in your authorized_keys file

#~~~~~~~~~~#
#~ config ~#
#~~~~~~~~~~#
server='zeus@192.168.1.30'
keyfile='.ssh/rsync' #~path to ssh priv key
remove_after_copy='true' #~bool should local files be removed after sync? accepts: [true|false]
#~array of directories to sync
#~syntax 'local/directory:remote/directory'
#~dont forget remote path is relative to one specified in your auth_keys file on the server
#~needs full paths because of hows the directories array is parsed
directories=('/sdcard/Pictures/Reddit/:nsfw/pics/reddit/' '/sdcard/Pictures/Twitter/:nsfw/pics/twitter/phone_saves/')

#~~~~~~~~~~~~~#
#~ Functions ~#
#~~~~~~~~~~~~~#
_removeCopy() {
    [ "$remove_after_copy" = "true" ] && printf '%s' '--remove-source-files'
}

#~~~~~~~~~~~~~~~~~~~~~~#
#~ スクリプトスタート ~#
#~~~~~~~~~~~~~~~~~~~~~~#
for i in "${directories[@]}"; do
    #~2775 for plex and smb users
    rsync $(_removeCopy) --progress -a --chmod 2775 -e "ssh -i $keyfile" "${i%:*}" "$server:""${i#*:}"
done
