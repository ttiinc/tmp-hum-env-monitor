#! /bin/sh
#
# +-------------------------------------------------------------------------+
# | Envirionment Logging                                                    |
# +-------------------------------------------------------------------------+
# | Copyright (C) 2019 Waldemar Schroeer                                    |
# |                    waldemar.schroeer@de.ttiinc.com
# +-------------------------------------------------------------------------+
# |  This program is free software: you can redistribute it and/or modify   |
# |  it under the terms of the GNU General Public License as published by   |
# |  the Free Software Foundation, either version 3 of the License, or      |
# |  (at your option) any later version.                                    |
# |                                                                         |
# |  This program is distributed in the hope that it will be useful,        |
# |  but WITHOUT ANY WARRANTY; without even the implied warranty of         |
# |  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          |
# |  GNU General Public License for more details.                           |
# |                                                                         |
# |  You should have received a copy of the GNU General Public License      |
# |  along with this program.  If not, see <http://www.gnu.org/licenses/>.  |
# +-------------------------------------------------------------------------+

printf "\nStart"
source /usr/local/bin/monitor-env-whs.conf

function notifybymail {
    printf "\n\nVisual Graphs\n  http://hostname.fqdn/whs-env/" >> /tmp/mailbody.$$
    printf "\n\nLong Term Log\n  http://hostname.fqdn/whs-env/longtermlog" >> /tmp/mailbody.$$
    ${mailx} -r "${sender}" -s "$1" ${recipient} < /tmp/mailbody.$$
    rm /tmp/mailbody.$$
}

count0=1
printf "\n----------------------------------------------------------\n" >> ${logdir}/${dateyear}_${datemonth}.txt
printf "${datefull}" >> ${logdir}/${dateyear}_${datemonth}.txt
while [ "${count0}" -lt "${boxes}" ]; do
    tempraw=`${snmpget} messpc-box${count0}.fqdn ${oidtemp}`
    humiraw=`${snmpget} messpc-box${count0}.fqdn ${oidhumi}`
    temp=`echo "scale=1; ${tempraw} / 10" | ${bc} -l`
    humi=`echo "scale=1; ${humiraw} / 10" | ${bc} -l`
    printf "\n      MessPC-Box${count0}" >> ${logdir}/${dateyear}_${datemonth}.txt
    printf "\n              Temperature: ${temp} C" >> ${logdir}/${dateyear}_${datemonth}.txt
    printf "\n                 Humidity: ${humi} %%" >> ${logdir}/${dateyear}_${datemonth}.txt

    if [ ${tempraw} -gt ${temphighwarn} ]
    then
        if [ ${tempraw} -gt ${temphighcrit} ]
        then
            # write mail crit
            printf "Hi,\n\nmesspc-box${count0} has reached critical temperature level.\nCurrent Value is: ${temp} C" > /tmp/mailbody.$$
            notifybymail "Temperatur Critical"
        else
            # write mail warn
            printf "Hi,\n\nmesspc-box${count0} has reached warning temperature level.\nCurrent Value is: ${temp} C" > /tmp/mailbody.$$
            notifybymail "Temperatur Warning"
        fi
    fi

    if [ ${humiraw} -gt ${humihighwarn} ]
    then
        if [ ${humiraw} -gt ${humihighcrit} ]
        then
            # write mail crit
            printf "Hi,\n\nmesspc-box${count0} has reached critical humidity level.\nCurrent Value is: ${humi}%%" > /tmp/mailbody.$$
            notifybymail "Humidity Critical"
        else
            # write mail warn
            printf "Hi,\n\nmesspc-box${count0} has reached warning humidity level.\nCurrent Value is: ${humi}%%" > /tmp/mailbody.$$
            notifybymail "Humidity Warning"
        fi
    fi

    if [ ${tempraw} -lt ${templow0crit} ]
    then
        # write mail crit
        printf "Hi,\n\nmesspc-box${count0} has reached critical temperature level.\nCurrent Value is: ${temp} C" > /tmp/mailbody.$$
        notifybymail "Temperatur Critical"
    fi

    if [ ${humiraw} -lt ${humilow0crit} ]
    then
        # write mail crit
        printf "Hi,\n\nmesspc-box${count0} has reached critical humidity level.\nCurrent Value is: ${humi}%%" > /tmp/mailbody.$$
        notifybymail "Humidity Critical"
    fi

    count0=`expr ${count0} + 1`
done
printf "\n----------------------------------------------------------\n" >> ${logdir}/${dateyear}_${datemonth}.txt

printf "\nStop"
exit 0

