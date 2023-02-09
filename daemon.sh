#!/usr/bin/env bash

PLAYLIST=/home/shared-stuff/playlist
while :; do
	[[ ! -f /var/lock/playerdaemon ]] && exit
	if [ ! -s $PLAYLIST ]; then
		sleep 1s
		continue
	fi

	aplay `cat $PLAYLIST | head -1` >/dev/null 2>&1
	sed -i '1d' $PLAYLIST
done
