#!/bin/sh

# Source:
# https://stackoverflow.com/questions/3570591/cli-pdf-viewer-for-linux

in="${1}"
if [ "${1}x" == "x" ]
then
    echo "Usage:"
    echo "${0} <PDF file>"
    exit 1
fi

gs \
   -dBATCH \
   -dNOPAUSE \
   -sDEVICE=txtwrite \
   -sOutputFile=- \
   ${in}
