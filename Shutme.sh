#!/bin/sh

# Last Updated Time-stamp: "Friday, 30-Oct-26 11:41:48 mb"

# Execute as superuser, or the user should be a part of the operator
# group.
sync && /sbin/shutdown -p now
