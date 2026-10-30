#!/bin/sh

# Last Updated Time-stamp: "Friday, 30-Oct-26 11:30:34 mb"

# This is used to verify the checsums of tar archives created by
# BackupHomeDir.sh

tmpcs='checksum.sha512'
for cs in $(ls -1 *sha512)
do
    sed 's|/tmp/backup/||g'  ${cs} > ${tmpcs}
    /sbin/sha512sum -c ${tmpcs}
    rm -f ${tmpcs}
done
