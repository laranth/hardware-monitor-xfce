#!/usr/bin/env bash

# Portable directory
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Size used for the icons is 24x24 (16x16 is also ok for a smaller panel)
readonly ICON="${DIR}/icons/fan.png"

# RPM values -- the "ASUS TUF GAMING X670E-PLUS" needs a "modprobe nct6775" to get these to work
# sensors.conf:
#   chip "nct6799-isa-0290"
#     label fan1 "CHA1"
#     label fan2 "CPU"
#     label fan3 "CHA2"
#     label fan4 "CHA3"
#     label fan5 "CHA4"
#     label fan6 "W_PUMP+"
#     label fan7 "AIO_PUMP"
readonly CPU="$( sensors | grep fan2 | awk '{printf "%4d", $2}')"
readonly CHA1="$(sensors | grep fan1 | awk '{printf "%4d", $2}')"
readonly CHA3="$(sensors | grep fan4 | awk '{printf "%4d", $2}')"

# Panel
PANEL=""
if [[ $(file -b "${ICON}") =~ PNG|SVG ]]; then
  PANEL+="<img>${ICON}</img>"
  if hash xfce4-taskmanager &> /dev/null; then
      PANEL+="<click>xfce4-taskmanager</click>"
  fi
fi
PANEL+="<txt>${CPU} RPM</txt>"

# Tooltip
TOOLTIP="<tool><span font_desc='Source Code Pro Regular'>FANS ==========="
TOOLTIP+="\nCPU\t${CPU} RPM"
TOOLTIP+="\nCHA1\t${CHA1} RPM"
TOOLTIP+="\nCHA3\t${CHA3} RPM</span></tool>"

# Output panel
echo -e "${PANEL}"

# Output hover menu
echo -e "${TOOLTIP}"
