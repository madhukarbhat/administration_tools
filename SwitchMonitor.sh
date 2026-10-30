#!/bin/sh

# Last Updated Time-stamp: "Friday, 30-Oct-26 11:43:15 mb"

# This sets up an external monitor as extended desktop on an OpanBSD
# OS. Native Resolution of VGA1 [ LG FLATRON L1753S ] - 1280x1024 @
# 60Hz

xrandr --output LVDS1 --auto --primary --output VGA1 --auto --right-of LVDS1
/usr/local/bin/openbsd-wallpaper
