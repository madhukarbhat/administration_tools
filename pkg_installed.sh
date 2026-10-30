#!/bin/sh

# Last Updated Time-stamp: "Friday, 30-Oct-26 11:52:10 mb"

# Query local sqlite3 database of the FreeBSD package tool to see
# installed packages.

dbfile="/var/db/pkg/local.sqlite"

out='pkg_installed.csv'

sql=$(cat <<"EOF"
SELECT
    origin  AS ORIGIN,
    name    AS NAME,
    version AS VERSION,
    strftime('%Y-%m-%d %H:%M:%S', time, 'unixepoch', 'localtime') AS INSTALL_TIME
FROM
    packages
WHERE
    time > strftime('%s', datetime('now', '-1 day'))
ORDER BY
    time DESC
EOF
   )

sqlite3 -header -separator $'\t'  "${dbfile}" "${sql}" > "${out}"
echo "[output] Packages installed in last 24 hours: ${out}"
