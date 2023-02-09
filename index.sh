#!/bin/bash
printf "Content-type: text/html\n\n"

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

export PLAYLIST=/home/shared-stuff/playlist
if [[ ! -f /var/lock/playerdaemon ]]; then
	truncate -s 0 $PLAYLIST
	touch /var/lock/playerdaemon
	nohup /usr/lib/cgi-bin/daemon.sh >/dev/null 2>&1 &
fi

soubory=$(ls /home/shared-stuff/down_music | while read line; do echo '<button class="buttonToLink" type="submit" name="songToPlay" value="'$line'">'${line//_/ }'</button><br>'; done; )

if [[ ! -z $CONTENT_LENGTH ]]; then
if [[ $CONTENT_LENGTH > 0 ]]; then
read -n $CONTENT_LENGTH
if [[ $REPLY ]]; then
	eval ${REPLY//&/;}
if [[ $songToDownload ]]; then
	echo "<i>Stahuji...</i>"
	nohup youtube-dl -f ba -x --audio-format wav --restrict-filenames -o '/home/shared-stuff/down_music/%(title)s.%(ext)s' $(urldecode "$songToDownload") >/dev/null 2>&1 &

elif [[ $songToPlay ]]; then
	echo /home/shared-stuff/down_music/$(urldecode "$songToPlay") >> $PLAYLIST

elif [[ "$stopmusic" = 1 ]]; then
	rm /var/lock/playerdaemon
	killall -s SIGKILL aplay
	truncate -s 0 $PLAYLIST

elif [[ "$skipthis" = 1 ]]; then
	killall -s SIGKILL aplay

elif [[ $vol ]]; then
	amixer -q -M set 'Headphone' $(urldecode "$vol")

elif [[ "$toggleMute" = 1 ]]; then
	amixer -q set 'Headphone' toggle
fi
fi
fi
fi

cat <<EOT
<style>
.buttonToLink { 
     background: none;
     border: none;
     color: #1a0dab;
     cursor: pointer;
	 text-align: right;
	 display: contents;
}
</style>

<h2>Ovladaci panel</h2>

<form action="" method="post">
$(amixer -M get Headphone | grep 'Mono:')&nbsp;&nbsp;&nbsp;
<br>
<button name="vol" value="8%+">+</button>
<button name="vol" value="8%-">-</button>
<button name="toggleMute" value="1">Mute</button>
<button value="1" name="skipthis">Preskocit</button>
<button value="1" name="stopmusic">Prestat prehravat a vymazat playlist</button>
</form>

YT link:
<form action="" method="post">
<input type="text" id="songToDownload" name="songToDownload" />
<input type="submit" value="Stahni!" />
</form>
EOT

cat <<EOT
<form action="" method="post">
$soubory
</form>
EOT

echo '<b><font size="+1">Playlist</font></b>'
bold="</b>"
playlist=`cat $PLAYLIST | while read line; do echo $(basename -- $line .${line##*.}); printf "<br>$bold"; bold=''; done;`
playlist=${playlist//_/ }
[[ ! -s $PLAYLIST ]] && echo "<i>playlist je prazdny.</i><pre></pre>" || echo '<pre><b>'$playlist'</pre>'

printf '<a href="index.sh">Nacist znovu</a>'
