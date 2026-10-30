#!/bin/sh

# Last Updated Time-stamp: "Friday, 30-Oct-26 11:49:40 mb"

# USECASE:
#
# When one is inside a local console on a host and needs to launch
# only one GUI application like one xterm ( for unicode characters ),
# xpdf, emacs, image viewer and does not want to launch a whole
# desktop environment.

# NOTE:
#
# Find the size of X screen with the following and put in the value
# for ${dim}
#
# xdpyinfo | grep dimension | awk '{print $2}'

margin=0
dim='1366x768'
logdir='/tmp'
xinitrc_g="${HOME}/wd_x/twm_SpyHill/xinitrc.txt"

# -------------------------------------------------------------------------

show_usage () {
    echo 'Usage:'
    echo "  ${0} OPTION <file list>"
    echo ''
    echo 'Where OPTION can be one of the following:'
    echo ''
    echo '    pdf - Displays the PDF file with /usr/local/bin/xpdf in a'
    echo '          dedicated X session. Provide file as <file list>.'
    echo ''
    echo '    img - Displays the image or the images in the directory in a'
    echo '          dedicated X Session using /usr/local/bin/feh utility.'
    echo '          Provide file as <file list>.'
    echo ''
    echo '  emacs - Executes /usr/local/bin/emacs in a console with'
    echo '          additional paramters. Additional parameters optional.'
    echo ''
    echo ' emacsg - Executes /usr/local/bin/emacs in a dedicated X session'
    echo '          with additional paramters. Additional parameters optional.'
    echo ''
    echo '  xterm - Executes /usr/local/bin/xterm in a dedicated X session'
    echo '          for use as a full screen GUI console.'
    echo ''
    echo '    twm - Starts the minimal Window Manager TWM. No additional'
    echo '          parameters needed.'
    echo ''
    echo '   help - Displays this help'
    echo ''
    return
}

# -------------------------------------------------------------------------

setup_global () {
    c0=$(echo "${dim}" | awk -F 'x' '{print $1}')
    r0=$(echo "${dim}" | awk -F 'x' '{print $2}')
    c1=$(echo "${c0}-${margin}" | bc)
    r1=$(echo "${r0}-${margin}" | bc)
}

# -------------------------------------------------------------------------

setup_pdf () {
    app='/usr/local/bin/xpdf'
    log="${logdir}/spdf.sh.log"
}

# -------------------------------------------------------------------------

setup_image () {
    app='/usr/local/bin/feh -F'
    log="${logdir}/simg.sh.log"
}

# -------------------------------------------------------------------------

setup_xterm () {
    app='/usr/local/bin/xfce4-terminal --geometry='135x33'  --fullscreen --hide-menubar'
    log="${logdir}/xterm.sh.log"
}

# -------------------------------------------------------------------------

setup_gui_emacs () {
    app='/usr/local/bin/emacs  --fullscreen '
    log="${logdir}/emacsg.sh.log"
}

# -------------------------------------------------------------------------
exec_console_emacs () {
    env TERM=xterm-256color emacs --eval "(load-theme 'tsdh-dark t)" -nw "$@"
}

# -------------------------------------------------------------------------

exec_twm () {
    XINITRC="${xinitrc_g}"
    if [ -e ${XINITRC} ]
    then
        startx ${XINITRC}
    else
        echo "[Abort] Cannot find ${XINITRC}"
        exit 1
    fi
    return
}

# -------------------------------------------------------------------------

main () {
    option="${1}"
    shift
    case ${option} in
	pdf)
	    setup_pdf
	    ;;
	img)
	    setup_image
	    ;;
	xterm)
	    setup_xterm
	    ;;
	emacsg)
	    setup_gui_emacs "$@"
	    ;;
	emacs)
	    exec_console_emacs "$@"
	    return
	    ;;
	twm)
	    exec_twm "$@"
	    return
	    ;;
	help)
	    show_usage
	    exit 1
	    ;;
	*)
	    echo "[Error] Unable to recognise option: ${option}"
	    echo ''
	    show_usage
	    exit 2
	    ;;
    esac
    if [ "${option}" == "xterm" ]
    then
        xinit ${app} -- :2 2> ${log}
    else
        xinit ${app} -geometry ${c1}x${r1} "$@" -- :2 2> ${log}
    fi
    return
}

# -------------------------------------------------------------------------

validate() {
    if [ "${1}x" == 'x' ]
    then
        show_usage
        exit 1
    fi

    if [ "${1}" == 'pdf' ] || [ ${1} == 'img' ] && [ $# -ne 2 ]
    then
	echo "[Error] Expected 2 parameters, got $#."
	echo ''
	show_usage
	exit 1
    elsif [ $# -ne 1 ]
	echo "[Error] Expected 1 parameter, got $#."
	echo ''
	show_usage
	exit 1
    fi
    return
}

# -------------------------------------------------------------------------

validate "$@"
setup_global
main "$@"

# -------------------------------------------------------------------------
# End
