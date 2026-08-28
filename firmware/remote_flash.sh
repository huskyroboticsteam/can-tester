#!/bin/bash
# Remotely flash an ESP32 SoC
# App-only. Does not flash bootloader or partition table

REMOTE="pi@rpi.local"
ESPTOOL_VENV="/home/pi/esptool/"

# exit immediately on failure
set -e

cd ./build

# copy .bin file to remote
scp firmware.bin $REMOTE:$ESPTOOL_VENV

# run flash utility on remote
ARGS=$(tr '\n' ' ' < flash_app_args)  # get app-only flash args
ssh "$REMOTE" "cd '$ESPTOOL_VENV' && ./bin/python -m esptool --chip esp32 -p /dev/ttyUSB0 -b 460800 --before=default-reset --after=hard-reset write-flash $ARGS"
