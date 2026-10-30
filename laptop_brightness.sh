#!/bin/sh

# Time-stamp: "Sunday, 05-Jan-2025 22:41:16 mb"
#           : "Sunday, 19-Nov-2023 20:39:30 mb"

# -----------------
# About the script:
# -----------------
#
# This is a one line utility to set laptop screen brightness on
# FreeBSD 13-RELEASE

default='50'
percent="${1}"
if [ "${percent}x" == "x" ]
then
    percent=${default}
    echo '[Info] to change brightness use a value between 1 and 100.'
    echo '[Info] This script uses command "backlight" for this purpose.'
fi

backlight -f /dev/backlight/backlight0 ${percent}
