#!/bin/sh

# Last Updated Time-stamp: <Friday, 30-Oct-26 11:02:14 mb>

# The output will display a symbol between the package name and the
# repository version indicating its status:
# 
#     < : Your installed package is outdated. An update is available
#         in the repository.
#
#     = : Your installed version is up-to-date with the repository.
#
#     > : Your installed version is newer than what is in the
#         repository (common if you compiled it yourself from ports
#         with custom options).
#

# -------------------------------------------------------------------------
# Print usage

usage() {
    echo ''
    echo 'Usage:'
    echo "    ${0} <pkg_01> <pkg_02> ... <pkg_nn>"
    echo ''
    echo 'Uses the binary update tool pkg to compare the version installed'
    echo 'with the version available in the remote repository. The output'
    echo 'will display a symbol between the package name and the repository'
    echo 'version indicating its status:'
    echo ''
    echo '    < : Your installed package is outdated. An update is available'
    echo '        in the repository.'
    echo ''
    echo '    = : Your installed version is up-to-date with the repository.'
    echo ''
    echo '    > : Your installed version is newer than what is in the'
    echo '        repository (common if you compiled it yourself from ports'
    echo '        with custom options).'
    return
}

# -------------------------------------------------------------------------
compare () {
    pkg_list="$@"
    if [ "${pkg_list}x" == "x" ]
    then
	echo '[Alert] No package list found'
	usage
	return 1
    fi

    for package in ${pkg_list}
    do
	pkg version -v -R -x ^${package}$
    done

    return 0
}

# -------------------------------------------------------------------------
# Main: Call compare

compare "$@"

# -------------------------------------------------------------------------
# End
