#!/usr/bin/env bash
# little script to add categories to newsboat opml file.

# config
outputFile="./newsboat_$(date +%y.%m.%d)_export.opml" # your new OPML file with categories
createNewsboatOPML="yes" #bool do you want the script to export newsboat urls to OPML for you? if yes it will also delete it when done.
# if no, then you will need to create it yourself (newsboat --export-to-opml)
newsboatOPML="$HOME/.newsboat/newsboat_temp_OPML.opml" # where your exported OPML file is or will be if the script is doing if for you
newsboatURLS="$HOME/.newsboat/urls" # where is your newsboat urls file?
untaggedCategory="Unsorted" # category name for feeds that dont have a tag

# init stuff
unset cats
declare -A cats # our nice associative array/hashtable

# functions

_parseNewsboatFiles() {
    # reads exported newsboat file, then gets category from urls file and ads outline line to the corresponding cat in the hashtable.
    unset OPML
    declare -A OPML # table for OPML line and extracted url for matching. fmt: [url]=full_line
    RAWOPML=$(cat "$newsboatOPML") # use ram instead of disk I/O?
    RAWURLS=$(cat "$newsboatURLS")
    OPMLURLS=$(sed -n -e 's/.*xmlUrl="\(.*\)" html.*/\1/p' <<< "$RAWOPML")
    for URL in $OPMLURLS; do
        OPML[$URL]="$(sed -n -e "s|.*\(<.*$URL.*>\)|\1|p" <<< "$RAWOPML")"
    done
    for i in "${!OPML[@]}"; do
        categoryString=$(sed -n -e "s|$i\(.*\)|\1|p" <<< "$RAWURLS")
        eval categoryArray=($categoryString) # i know.. eval is bad, but idk how else make the array pay attention to the quotes.. just dont name your tags anything stupid like ');rm -rf /* #'
        if [[ "${#categoryArray[@]}" -lt "1" ]]; then
            cats[$untaggedCategory]+="${OPML[$i]}"
        else
            for category in "${categoryArray[@]}"; do
                cats[$category]+="${OPML[$i]}"
            done
        fi
    done
}

_createOPML() {
    _parseNewsboatFiles
    # spits collected data out in opml format(rough)
    printf '<?xml version="1.0" encoding="utf-8"?>
<opml version="2.0">
    <head>
        <dateCreated>%s</dateCreated>
        <title>Newsboat Exported</title>
        <docs />
    </head>
    <body>' "$(date)" > "$outputFile"
    for cat in "${!cats[@]}"; do
        printf '
        <outline type="rss" title="%s">' "$cat" >> "$outputFile"
        # would be _a lot_ easier if bash could do multi-dimensional arrays.. owell idk why i didnt just use python.
        IFSOLD="$IFS"
        IFS='>' read -ra feeds <<< "${cats[$cat]}"
        IFS=$IFSOLD
        for feed in "${feeds[@]}"; do
            printf '
            %s>' "$feed" >> "$outputFile"
        done
        printf '
        </outline>' >> "$outputFile"
    done
    printf '
    </body>
</opml>' >> "$outputFile"
}

_main() {
    if [[ "$createNewsboatOPML" == "yes" ]]; then
        newsboat --export-to-opml > "$newsboatOPML"
        _createOPML
        rm "$newsboatOPML"
    else
        _createOPML
    fi
}

_main
