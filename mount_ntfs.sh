#!/bin/bash
mount_dir='/mnt/ntfs'
sudo ntfs-3g /dev/da0p1 ${mount_dir}
if [ $? == 0 ]
then
    echo "[Mounted] ${mount_dir}"
fi
