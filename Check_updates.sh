#!/bin/sh

# Last Updated Time-stamp: "Friday, 30-Oct-26 11:38:47 mb"

# At the time when the base FreeBSD ws updated by freebsd-update,
# Ports maintained through pkg, this script was useful in just
# checking if there are any available updates. The actions are as below:
#
# - Check for Base OS updated, install any updates if any and exit the
#   script. The user is expected to reboot OS if needed and execute
#   this script again to check for updates to packages.
#
# - Check for updates to installed packages. Do not install the
#   updates. The user is expected to install the packages after
#   reviewing the list. The idea is to give the user an opportunity to
#   lock any packages that may have incompatible updates.
#
# - Update the ports collection git repository and display the
#   UPDATING entries for the past 1 month.


#--------------------------------------------------------------------------
# Globals


log_dir=$(dirname $(dirname $0))/osupdates
LOG=${log_dir}/$(basename $0).out.log
ERR=${log_dir}/$(basename $0).err.log
GITLOG=${log_dir}/$(basename $0)-git.out.log
GITERR=${log_dir}/$(basename $0)-git.err.log

#--------------------------------------------------------------------------
# Show versions of various components. Helps in identifying if a reboot
# is needed to sync up kernel and userland

show_versions() {
    echo '-----------------------------------------'
    echo -n '[Info] Installed kernel: ' && freebsd-version -k
    echo -n '[Info] Running kernel  : ' && freebsd-version -r
    echo -n '[Info] Userland version: ' && freebsd-version -u
    echo '-----------------------------------------'
    echo ''
}

#--------------------------------------------------------------------------
# Check for Base OS updates

check_and_install_baseos_updates() {
    freebsd-update fetch
    freebsd-update updatesready
    if [ $? -ne 2 ]
    then
        freebsd-update install
        show_versions
        return 100
    fi
    return 0
}

#--------------------------------------------------------------------------
# Check and update packages

show_available_pkg_upgrades() {
    tempstub=$(basename $0)
    TMPFILE=$(mktemp -q /tmp/${tempstub}.XXXXXX)
    if [ $? -ne 0 ]
    then
        echo "[Fatal] ${0}: Can't create temp file, exiting..."
        exit 1
    fi

    echo '-----------------------------------------'
    echo '[Info] Querying available package updates (dry run)'
    echo ''
    pkg upgrade -n | tee ${TMPFILE}
    echo ''

    no_updates=$(grep -c 'Your packages are up to date.' ${TMPFILE})
    if [ ${no_updates} -eq 0 ]
    then
        echo '[Info] Upgrades available.'
        echo "[Info] Execute 'pkg upgrade' as superuser to upgrade packages"
        echo ''
    fi
    rm -f ${TMPFILE}
}

#--------------------------------------------------------------------------
# Update ports. Utility portsnap is removed in 14.0-RELEASE. Hence,
# the following command cannot be used:
#
#   portsnap fetch update
#
# To setup ports:
# git clone https://git.FreeBSD.org/ports.git /usr/ports
#
# To update ports:
# git -C /usr/ports pull
update_ports() {
    echo '-----------------------------------------'
    echo '[Info] Updating ports:'
    echo ''

    git -C /usr/ports pull 2> ${GITERR} > ${GITLOG}

    echo ''
    echo '-----------------------------------------'
    echo '[Info] Entries in UPDATING for the last 1 month:'
    echo ''
    pkg updating -d $(date -v-1m +%Y%m%d)
}


#--------------------------------------------------------------------------
# Validate effective user

validate() {
    current_user=$(id -u)
    if [ ${current_user} -ne 0 ]
    then
        echo '[Fatal] This script must be executed as root. Abort.'
        exit 1
    fi
}

#--------------------------------------------------------------------------
# Main
main() {
    show_versions
    check_and_install_baseos_updates
    if [ $? -eq 0 ]
    then
        echo '[Info] Base OS update complete'
        echo ''
        show_available_pkg_upgrades | sed 's///g'
        update_ports
    fi
    echo '[Done]'
    return
}

#--------------------------------------------------------------------------
# Call Main

validate
main 2> ${ERR} | tee ${LOG}
echo '----'
echo "[LOGDIR] ${log_dir}"
wc -l ${log_dir}/*

#--------------------------------------------------------------------------
# End
