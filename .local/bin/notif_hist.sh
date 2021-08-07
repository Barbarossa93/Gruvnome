#!/usr/bin/sh

notif_log=/tmp/notif_hist
count=/tmp/notif_count

query() {
	# Set to never time out, reverse order and attempts to dedup, doesnt work great
	notifs=$(tac $notif_log | sed -e 's/SEC:[0-9]\+/SEC:0/g' -e t -e 's/^/SEC:0\t/' | cat -n | sort -uk2 | sort -nk1 | cut -f2-)

	#if test $(find "$count" -mmin +1); then
	#	rm $count
	#fi
	if [ ! -f "$count" ]; then
		echo 1 >$count
	fi
	c=$(cat $count)
	pkill -USR1 xnotify
	echo "$notifs" | awk "NR==$c" >"$XNOTIFY_FIFO" &
	c=$((c + 1))
	echo "$c" >$count
}

cleanup() {
	[ -f $count ] && rm $count
	pkill -USR1 xnotify
}

case "$1" in
-c | --cleanup)
	cleanup
	;;
-q | --query | *)
	query
	;;
esac
