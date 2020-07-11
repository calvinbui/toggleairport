#!/usr/bin/env bash
#git@github.com:paulbhart/toggleairport.git
#originally from https://gist.github.com/albertbori/1798d88a93175b9da00b

sudo rm /Library/Scripts/toggleAirport.sh
launchctl unload /Library/LaunchAgents/com.mine.toggleairport.plist
sudo rm  /Library/LaunchAgents/com.mine.toggleairport.plist

rm -f /var/tmp/prev_eth_on
rm -f /var/tmp/prev_air_on
rm -f /var/tmp/prev_toggle_airport_run
