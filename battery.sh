#!/bin/sh
# This is used within main.conky

stdalone=${1}

life=$(sysctl hw.acpi.battery.life | awk '{print "("$2"%)"}')
tt0=$(sysctl hw.acpi.battery.time | awk '{print $2}')
tt1="$(echo "scale=2;${tt0}/60" | bc)  Hours"
is_on_ac=$(sysctl  hw.acpi.acline | awk '{print $2}')
if [ ${is_on_ac} == 1 ]
then
    tt1="Charging"
fi  
echo -n "${tt1}, ${life}"

if [ "${stdalone}x" != "x" ]
then
    echo ''
    echo '--------'

    acpi=$(which acpiconf)
    if [ -e ${acpi} ]
    then
        acpiconf  -i 0
    fi
fi
