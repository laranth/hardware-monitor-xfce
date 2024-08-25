#!/usr/bin/env bash

# Portable directory
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Size used for the icons is 24x24 (16x16 is also ok for a smaller panel)
readonly ICON="${DIR}/icons/gpu.png"

# GPU values
readonly GPU_NAME="$(      nvidia-smi --query-gpu=name               --format=csv,noheader)"
readonly GPU_TEMP="$(      nvidia-smi --query-gpu=temperature.gpu    --format=csv,noheader,nounits)"
readonly CUDA_VERSION="$(  nvidia-smi -q -d performance | grep "CUDA Version" | sed "s/[^0-9'.]//g")"  # includes the dot
readonly DRIVER_VERSION="$(nvidia-smi --query-gpu=driver_version     --format=csv,noheader)"
readonly GPU_UTIL="$(      nvidia-smi --query-gpu=utilization.gpu    --format=csv,noheader,nounits)"
readonly GPU_MEMORY="$(    nvidia-smi --query-gpu=utilization.memory --format=csv,noheader,nounits)"
readonly GPU_POWER="$(     nvidia-smi --query-gpu=power.draw.instant --format=csv,noheader,nounits)"
readonly GPU_FAN_SPEED="$( nvidia-smi --query-gpu=fan.speed          --format=csv,noheader,nounits)"
readonly GPU_TOTAL_MEM="$( nvidia-smi --query-gpu=memory.total       --format=csv,noheader,nounits)"
readonly TOPGPU="$(        nvidia-smi -q | grep -A 3 'Process ID' | awk -v RS='--\n' -v FS='\n|:' -v TM=${GPU_TOTAL_MEM} 'gsub(" MiB", "", $8) {printf "%5.2f%% %s\n", $8 / TM, $6}'| sort -rn)"

# Panel
PANEL=""
if [[ $(file -b "${ICON}") =~ PNG|SVG ]]; then
  PANEL+="<img>${ICON}</img>"
  if hash xfce4-taskmanager &> /dev/null; then
      PANEL+="<click>xfce4-taskmanager</click>"
  fi
fi
PANEL+="<txt>${GPU_UTIL}% @ $GPU_TEMP"°C" </txt>"

# Tooltip
TOOLTIP="<tool><span font_desc='Source Code Pro Regular'>${GPU_NAME}\n"
TOOLTIP+="\nSTATUS =================="
TOOLTIP+="\nGPU Load\t${GPU_UTIL}%"
TOOLTIP+="\nTemperature\t${GPU_TEMP}°C"
TOOLTIP+="\nMemory Used\t${GPU_MEMORY}%"
TOOLTIP+="\nPower Draw\t${GPU_POWER}W"
TOOLTIP+="\nFan Speed\t${GPU_FAN_SPEED}%"
TOOLTIP+="\n"
TOOLTIP+="DRIVERS =================\n"
TOOLTIP+="NVIDIA\t\t${DRIVER_VERSION}\n"
TOOLTIP+="CUDA\t\t${CUDA_VERSION}\n"
TOOLTIP+="\n"
TOOLTIP+="GPU MEMORY USAGE ========\n"
TOOLTIP+="${TOPGPU}"
TOOLTIP+="</span></tool>"

# Output panel
echo -e "${PANEL}"

# Output hover menu
echo -e "${TOOLTIP}"
