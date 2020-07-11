#!/usr/bin/env bash
#git@github.com:paulbhart/toggleairport.git
#originally from https://gist.github.com/albertbori/1798d88a93175b9da00b

sudo cp ./toggleAirport.sh /Library/Scripts/
sudo chmod 755 /Library/Scripts/toggleAirport.sh

sudo cp ./com.mine.toggleairport.plist /Library/LaunchAgents/
sudo chown root /Library/LaunchAgents/com.mine.toggleairport.plist
sudo chmod 644 /Library/LaunchAgents/com.mine.toggleairport.plist
launchctl load /Library/LaunchAgents/com.mine.toggleairport.plist
