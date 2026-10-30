#!/bin/sh

# Last Updated Time-stamp: "Friday, 30-Oct-26 11:29:18 mb"

# This creates a set of Tar Bzip2 archives of /etc, /usr/local/etc and
# the user HOME directory after ignoring ~/.cache, ~/.dbus,
# ~/.mutt/cache directories.

bkp_owner=mb
hd="${HOME}"
wd=$(dirname ${hd})
bt=./$(basename ${hd})
od="/tmp/backup"
tm="${od}/backup-list.txt"
op="${od}/mb-$(date +%Y-%m-%d-%H-%M-%S-%Z).tbz2"

if [ ! -e ${od} ]
then
  mkdir ${od}
fi

echo "[info] Starting - back up of ${HOME} to ${op}"
cd ${wd}
find ${bt} \
  -path ${bt}/.cache -prune -o \
  -path ${bt}/.dbus -prune -o \
  -path ${bt}/.mutt/cache -prune -o \
  -type f -print > ${tm}

tar -v -C ${wd} -j -c -f ${op} -I ${tm}
sha512 ${op} > ${op}.sha512
echo "[info] Complete - back up of ${HOME} to ${op}"

echo "[info] Starting - backup of /etc ..."
op="${od}/etc-$(date +%Y-%m-%d-%H-%M-%S-%Z).tbz2"
cd / && sudo tar -jcf ${op} ./etc
sha512 ${op} > ${op}.sha512
sudo chown ${bkp_owner} ${op}
echo "[info] Complete - backup  of /etc to ${op}"

echo "[info] Starting - backup of /usr/local/etc ..."
op="${od}/usr-local-etc-$(date +%Y-%m-%d-%H-%M-%S-%Z).tbz2"
cd / && sudo tar -jcf ${op} ./usr/local/etc
sha512 ${op} > ${op}.sha512
sudo chown ${bkp_owner} ${op}
echo "[info] Complete - backup  of /usr/local/etc to ${op}"

echo "[info] Starting - backup of packages list ..."
op="${od}/pkgs-list-$(date +%Y-%m-%d-%H-%M-%S-%Z).txt"
pkg prime-origins | tee ${op}

echo "[info] Complete - backup of packages list ..."
