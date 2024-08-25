#!/usr/bin/env bash
# Dependencies: bash>=3.2, coreutils, file, gawk

# Portable directory
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Size used for the icons is 24x24 (16x16 is also ok for a smaller panel)
readonly ICON="${DIR}/icons/memory.png"

# Calculate RAM values
readonly TEMP=$(free -b | grep Mem)
readonly TOTAL=$(    echo ${TEMP} | awk '{printf "%8.2f", $2 / 2^30}')
readonly USED=$(     echo ${TEMP} | awk '{printf "%8.2f", $3 / 2^30}')
readonly FREE=$(     echo ${TEMP} | awk '{printf "%8.2f", $4 / 2^30}')
readonly SHARED=$(   echo ${TEMP} | awk '{printf "%8.2f", $5 / 2^30}')
readonly CACHED=$(   echo ${TEMP} | awk '{printf "%8.2f", $6 / 2^30}')
readonly AVAILABLE=$(echo ${TEMP} | awk '{printf "%8.2f", $7 / 2^30}')

## # Swap Values
## readonly SWP_TOTAL=$(free -b | awk '/^[Ss]wap/{$2 = $2 / 1073741824; printf "%.2f", $2}')
## readonly SWP_USED=$(free -b | awk '/^[Ss]wap/{$3 = $3 / 1073741824; printf "%.2f", $3}')
## readonly SWP_FREE=$(free -b | awk '/^[Ss]wap/{$4 = $4 / 1073741824; printf "%.2f", $4}')

# RAM value in percentage
readonly USED_PERCENT=$(echo ${TEMP} | awk '{ printf("%3d%\n", 100.0 * $3/$2) }')

# top memory users
readonly TOPMEM=$(ps ax -o pmem,comm --no-headers --sort -pmem | head | awk '{$1=sprintf("%6.2f%%",$1); gsub("Isolated Web Co", "firefox-isolated", $0);}1')

# Panel
PANEL=""
if [[ $(file -b "${ICON}") =~ PNG|SVG ]]; then
  PANEL+="<img>${ICON}</img>"
  if hash xfce4-taskmanager &> /dev/null; then
    PANEL+="<click>xfce4-taskmanager</click>"
  fi
fi
PANEL+="<txt> ${USED_PERCENT}  </txt>"

# Tooltip
TOOLTIP="<tool><span font_desc='Source Code Pro Regular'>RAM ================"
TOOLTIP+="\nUsed\t${USED} GB"
TOOLTIP+="\nFree\t${FREE} GB"
TOOLTIP+="\nShared\t${SHARED} GB"
TOOLTIP+="\nCache\t${CACHED} GB"
TOOLTIP+="\nTotal\t${TOTAL} GB"
TOOLTIP+="\n"
TOOLTIP+="\nPROCESSES =========="
TOOLTIP+="\n${TOPMEM}</span></tool>"

# Output panel
echo -e "${PANEL}"

# Output hover menu
echo -e "${TOOLTIP}"
