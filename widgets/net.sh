#!/usr/bin/env bash

# Portable directory
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Size used for the icons is 24x24 (16x16 is also ok for a smaller panel)
readonly ICON="${DIR}/icons/net.png"

readonly IF="enp9s0f1"

# Get Network Information
readonly IFCONFIG_BEFORE="$(ifconfig ${IF})"
readonly IFCONFIG_AFTER="$(sleep 0.5 && ifconfig ${IF})"
readonly IFNAME="$(awk '/inet /{print $2}' <<< ${IFCONFIG_BEFORE})"
readonly IPV4="$(awk '/inet /{print $2}' <<< ${IFCONFIG_BEFORE})"
readonly IPV6="$(awk '/inet6/{print $2}' <<< ${IFCONFIG_BEFORE})"
readonly RXBYTES_BEFORE="$(awk '/RX packets/{print $5}' <<< ${IFCONFIG_BEFORE})"
readonly TXBYTES_BEFORE="$(awk '/TX packets/{print $5}' <<< ${IFCONFIG_BEFORE})"
readonly RXBYTES="$(awk -v B=${RXBYTES_BEFORE} '/RX packets/{printf "%4d", ($5 - B)/(2^10)}' <<< ${IFCONFIG_AFTER})"
readonly TXBYTES="$(awk -v B=${TXBYTES_BEFORE} '/TX packets/{printf "%4d", ($5 - B)/(2^10)}' <<< ${IFCONFIG_AFTER})"
# Anotehr idea https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/blob/master/scripts/monBandwidth

# Panel
PANEL=""
if [[ $(file -b "${ICON}") =~ PNG|SVG ]]; then
    PANEL+="<img>${ICON}</img>"
    if hash xfce4-taskmanager &> /dev/null; then
        PANEL+="<click>xfce4-taskmanager</click>"
    fi
fi
PANEL+="<txt>${RXBYTES} ${TXBYTES}</txt>"

# Tooltip
TOOLTIP="<tool><span font_desc='Source Code Pro Regular'>${IF} on ${HOSTNAME}\n"
TOOLTIP+="\nIPv4\t${IPV4}"
TOOLTIP+="\nDown\t${RXBYTES} KiBps"
TOOLTIP+="\nUp\t${TXBYTES} KiBps</span></tool>"

# Output panel
echo -e "${PANEL}"

# Output hover menu
echo -e "${TOOLTIP}"


