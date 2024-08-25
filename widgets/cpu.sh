#!/usr/bin/env bash

# Portable directory
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Size used for the icons is 24x24 (16x16 is also ok for a smaller panel)
readonly ICON="${DIR}/icons/cpu.png"

# get CPU info on 1-second interval
readonly CPU_LOAD=$(cat <(grep 'cpu ' /proc/stat) <(sleep 0.5 && grep 'cpu ' /proc/stat) | awk -v RS="" '{printf("%0.2f", ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5))}')
readonly CPU_SHORT=$(awk '{printf("%3.0f", $1)}' <<< "${CPU_LOAD}")
readonly TOPCPU=$(ps ax -o pcpu,comm --no-headers --sort -pcpu | head | awk '{$1=sprintf("%6.2f%%",$1); gsub("Isolated Web Co", "firefox-isolated", $0);}1')

# Available CPUs - threads are looked at as cores
declare -r CORE_ARRAY=($(awk '/MHz/{print $4}' /proc/cpuinfo | cut -f1 -d"."))
# Number of logical CPU
readonly CORES="${#CORE_ARRAY[@]}"
# Tempertature
readonly CPU_TEMP="$(sensors | grep -A 5 k10temp-pci-00c3 | grep Tctl | cut -f2- -d: | sed "s/[^0-9'.]//g")"
readonly CPU_TEMP_SHORT="$(awk '{printf "%2.0f", $1}' <<< ${CPU_TEMP})"

# Figure out the average frequency of the CPUs
IDLE_FREQ=400
MIN_FREQ=100000000
MAX_FREQ=0
for CORE_FREQ in "${CORE_ARRAY[@]}"; do
  AVG_FREQ=$(( AVG_FREQ + CORE_FREQ ))
  if ((CORE_FREQ < MIN_FREQ)); then
      MIN_FREQ=${CORE_FREQ}
  fi
  if ((CORE_FREQ > MAX_FREQ)); then
      MAX_FREQ=${CORE_FREQ}
  fi
done
AVG_FREQ=$(( AVG_FREQ / CORES )) # calculate average clock speed
IDLE_CORES=0
for CORE_FREQ in "${CORE_ARRAY[@]}"; do
    if (( CORE_FREQ == IDLE_FREQ )); then
        IDLE_CORES=$((IDLE_CORES+1))
    fi
done
MIN_FREQ=$(awk '{printf "%4d", $1}' <<< "${MIN_FREQ}")
AVG_FREQ=$(awk '{printf "%4d", $1}' <<< "${AVG_FREQ}")
MAX_FREQ=$(awk '{printf "%4d", $1}' <<< "${MAX_FREQ}")


# Tooltip
TOOLTIP="<tool><span font_desc='Source Code Pro Regular'>"
TOOLTIP+="$(grep "model name" /proc/cpuinfo | cut -f2 -d ":" | sed -n 1p | sed -e 's/^[ \t]*//' | sed 's/Processor//')\n" # CPU vendor, model, clock
TOOLTIP+="\nSTATUS =================="
TOOLTIP+="\nHalfSec Load:\t${CPU_LOAD}%"
TOOLTIP+="\nTemperature:\t${CPU_TEMP}°C"
TOOLTIP+="\nIdle Cores:\t${IDLE_CORES} of ${CORES}"
TOOLTIP+="\nMin Frequency:\t${MIN_FREQ} MHz"
TOOLTIP+="\nAvg Frequency:\t${AVG_FREQ} MHz"
TOOLTIP+="\nMax Frequency:\t${MAX_FREQ} MHz"
TOOLTIP+="\n"
TOOLTIP+="\nPROCESSES ==============="
TOOLTIP+="\n${TOPCPU}</span></tool>"


# Panel
PANEL=""
if [[ $(file -b "${ICON}") =~ PNG|SVG ]]; then
  PANEL+="<img>${ICON}</img>"
  if hash xfce4-taskmanager &> /dev/null; then
    PANEL+="<click>xfce4-taskmanager</click>"
  fi
fi
PANEL+="<txt>${CPU_SHORT}% @ ${CPU_TEMP_SHORT}"°C" </txt>"

# Output panel
echo -e "${PANEL}"

# Output hover menu
echo -e "${TOOLTIP}"
