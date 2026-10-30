#!/bin/sh

# Lasr Updated Time-stamp: <Friday, 30-Oct-26 11:52:54 mb>

# --------------------------------------------------------------------

show_usage() {
    usage="$(cat <<-EOF
Usage:

  ${0} <input filename pattern>

Where:

  <input filename pattern> - The name stub of files being renamed. For
    the output filename convention, edit the shell script as per
    need. Do not add wildcard character. This string is used in the
    shell script with sed to edit and remove it from output filename.

EOF
)"

    echo "${usage}"
    return
}

# --------------------------------------------------------------------

validate(){
    suffix='.pdf'
    stub="${1}"
    if [ "${stub}x" == "x" ]
    then
	echo '[Error] One command line parameter is expected.'
	show_usage
	exit 1
    fi
    return
}

# --------------------------------------------------------------------

get_month_no() {
    mon_in="${1}"
    mon=$(echo "${mon_in}" | tr "[A-Z]" "[a-z]")
    case "${mon}" in
	jan)
	    mon_num='01'
	    ;;
	feb)
	    mon_num='02'
	    ;;
	mar)
	    mon_num='03'
	    ;;
	apr)
	    mon_num='04'
	    ;;
	may)
	    mon_num='05'
	    ;;
	jun)
	    mon_num='06'
	    ;;
	jul)
	    mon_num='07'
	    ;;
	aug)
	    mon_num='08'
	    ;;
	sep)
	    mon_num='09'
	    ;;
	oct)
	    mon_num='10'
	    ;;
	nov)
	    mon_num='11'
	    ;;
	dec)
	    mon_num='12'
	    ;;
	*)
	    mon_num='-'
    esac
    echo "${mon_num}"
    return
    
}

# --------------------------------------------------------------------

get_out_filename(){
    in="${1}"
    sf="${2}"
    part=$(echo "${in}" | sed "s/^${stub}// ; s/${sf}$//")
    tmon=$(echo ${part} | awk -F '-' '{print $1}')
    year=$(echo ${part} | awk -F '-' '{print "20"$2}')
    mon=$(get_month_no ${tmon})
    fn="${year}-${mon}${sf}"
    echo "${fn}"
    return
}

# --------------------------------------------------------------------

main() {
    validate "$@"

    ls -1 "${stub}"* | while read ff
    do
	echo "[Info] Processing: ${ff}"
	of=$(get_out_filename "${ff}" "${suffix}")
	mv "${ff}" "${of}"
    done

    return
}

# --------------------------------------------------------------------

main "$@"

# --------------------------------------------------------------------
# End
