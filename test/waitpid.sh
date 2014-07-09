#!/bin/sh
/opt/bin/su admin -c "ping -c 5 localhost > /dev/null" &
pid1=$!
echo "$(/bin/date '+%F %T.%3N') waiting pid1: $pid1"
wait $pid1
echo "$(/bin/date '+%F %T.%3N') done"