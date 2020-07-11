#!/usr/bin/env bash
#git@github.com:paulbhart/toggleairport.git
#originally from https://gist.github.com/albertbori/1798d88a93175b9da00b

check_interval=5 # seconds
prev_air_on="/var/tmp/prev_air_on"
prev_eth_on="/var/tmp/prev_eth_on"

function set_airport {
  echo "setting airport $2 to $1"
  networksetup -setairportpower "$2" "$1"
}

function update_status {
  if [[ "$1" == "on" ]]; then
    echo "creating $2"
    touch "$2";
  else
    echo "deleting $2"
    rm -f "$2";
  fi
}

function notify {
  echo "sending macos notification"
  osascript -e "display notification \"$1\" with title \"Wi-Fi Toggle\""
}

# grab the names of the adapters. We assume here that any ethernet connection name ends in "Ethernet"
eth_names=$(networksetup -listnetworkserviceorder | sed -En 's/^\(Hardware Port: .*(Ethernet|LAN).* Device: (en[0-9]+)\)$/\2/p')
air_name=$(networksetup -listnetworkserviceorder | sed -En 's/^\(Hardware Port: (Wi-Fi|AirPort).* Device: (en[0-9]+)\)$/\2/p')

# Determine previous ethernet and wifi status
# If file exists, it was active last time we checked
if [[ -f "$prev_eth_on" ]]; then prev_eth_status="on"; else prev_eth_status="off"; fi
if [[ -f "$prev_air_on" ]]; then prev_air_status="on"; else prev_air_status="off"; fi

# get current ethernet status
eth_status="off"
for eth_name in $eth_names; do
  if [ "$eth_name" != "" ] && ifconfig "$eth_name" | grep -q "status: active"; then
    eth_status="on"
  fi
done

# And actual current Wi-Fi status
air_status=$(networksetup -getairportpower "$air_name" | awk 'NF>1{print tolower($NF)}')

echo "eth_names: $eth_names"
echo "eth_status: $eth_status"
echo "air_name: $air_name"
echo "air_statis: $air_status"
echo "prev_eth_on: $prev_eth_on"
echo "prev_eth_status: $prev_eth_status"
echo "prev_air_on: $prev_air_on"
echo "prev_air_status: $prev_air_status"

# if ethernet status has changed
if [[ "$prev_eth_status" != "$eth_status" ]]; then
  echo "eth status has changed"
  # if cable is plugged in, turn off wi-fi
  if [[ "$eth_status" == "on" ]]; then
    echo "turning off wifi"
    notify "Wired network detected. Turning Wi-Fi off."
    set_airport "off" "$air_name"
    update_status "on" $prev_eth_on
    update_status "off" $prev_air_on
  else
    echo "turning on wifi"
    notify "No wired network detected. Turning Wi-Fi on."
    set_airport "on" "$air_name"
    update_status "off" $prev_eth_on
  fi
# If ethernet did not change
else
  echo "no change detected"  # Check whether Wi-Fi status changed
  # If so it was done manually by user
  if [[ "$prev_air_status" != "$air_status" ]]; then
    set_airport "$air_status" "$air_name"
    # if [ "$air_status" = "on" ]; then
    #     notify "Wi-Fi manually turned on."
    # else
    #     notify "Wi-Fi manually turned off."
    # fi
  fi
fi

echo "sleeping until next run"
sleep $check_interval
