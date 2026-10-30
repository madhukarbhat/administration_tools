#!/bin/sh

# Last Updated Time-stamp: "Friday, 30-Oct-26 11:40:18 mb"

# This performs the same set of actions as Check_updates.sh, but for
# jails. The actions are as below:
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
script_name=$(basename ${0})

#--------------------------------------------------------------------------
# Show the command-line usage as this runs on Jails and hence needs
# the name of a jail to update

show_help() {
    echo 'Usage:'
    echo "    ${script_name} <jail name>"
    echo 'Where:'
    echo "    <jail name> is the name of the jail that should be udpated"
    return
}

#--------------------------------------------------------------------------
# Show versions of various components. Helps in identifying if a reboot
# is needed to sync up kernel and userland

show_versions() {
    echo '-----------------------------------------'
    echo -n '[Info] Jail Name       : '
    jexec ${jname} uname  -n
    
    echo -n '[Info] Operating System: '
    jexec ${jname} uname -rs

    echo -n '[Info] Running kernel  : '
    jexec ${jname} freebsd-version -r

    echo -n '[Info] Userland version: '
    jexec ${jname} freebsd-version -u
    echo '-----------------------------------------'
    echo ''
}

#--------------------------------------------------------------------------
# Check for Base OS updates

check_and_install_baseos_updates() {
    freebsd-update -j ${jname} fetch
    freebsd-update -j ${jname} updatesready
    if [ $? -ne 2 ]
    then
        freebsd-update -j ${jname} install
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
    pkg -j ${jname} upgrade -n | tee ${TMPFILE}
    echo ''

    no_updates=$(grep -c 'Your packages are up to date.' ${TMPFILE})
    if [ ${no_updates} -eq 0 ]
    then
        echo '[Info] Upgrades available.'
        echo "[Info] Execute 'pkg -j ${jname} upgrade' as "
	echo "       superuser to upgrade packages"
        echo ''
    fi
    rm -f ${TMPFILE}
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

    # One command-line parameter is mandatory.
    if [ $# -ne 1 ]
    then
	show_help
	exit 1
    else
	jname=${1}
    fi

    # Check if a jail exists by attempting to execute a command inside
    # it
    if ! jexec ${jname} date >/dev/null 2>&1
    then
	echo "[Fatal] Jail '${jname}' does not exist or is not running."
	echo '--'
	show_help
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
    fi
    echo '[Done]'
    return
}

#--------------------------------------------------------------------------
# Call Main

validate "$@"
main 2> ${ERR} | tee ${LOG}
echo '----'
echo "[LOGDIR] ${log_dir}"
wc -l ${log_dir}/*

#--------------------------------------------------------------------------
# End
