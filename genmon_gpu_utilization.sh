#!/usr/bin/bash

ICON=utilities-system-monitor
PARTITION=nvme2n1p2

# get CPU info
CPU=$(cat <(grep 'cpu ' /proc/stat) <(sleep 1 && grep 'cpu ' /proc/stat) | awk -v RS="" '{printf("%02d", ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5))}')
CPULOAD=$(uptime | tr -s " " | cut -d' ' -f9-)
TOPCPU=$(ps aux --no-headers | awk '{print $3 " "  $11}' | sort -rn | head -n 5)
 
# get memory info
MEMTOT=$(cat /proc/meminfo | grep MemTotal | awk '{printf ("% 0.1f", $2/1024000)}')
MEMAVA=$(cat /proc/meminfo | grep MemAvailable | awk '{printf ("%0.1f", $2/1024000)}')
MEMUSAGE=$(free | grep Mem | awk '{printf("%02d",  $3/$2 * 100.0)}')
MEMUSAGE2=$(echo "$MEMTOT GB in use")
MEMUSED=$(echo "scale=2;($MEMTOT - $MEMAVA)" | bc)
TOPMEM=$(ps aux --no-headers | awk '{print $4 " "  $11}' | sort -rn | head -n 5)
 
# get hard drive usage info 
HD=$(df -hl /dev/$PARTITION | grep $PARTITION | awk '{printf ("%02d", $5)}' | sed -e 's/%//')
HDUSED=$(df -hl /dev/$PARTITION | grep $PARTITION | awk '{print $3}' | sed -e 's/G//')
HDSIZE=$(df -hl /dev/$PARTITION | grep $PARTITION | awk '{print $2}' | sed -e 's/G//')
TOPHD=$(df -hl /dev/$PARTITION | tail -1)

# Collect GPU Utilization %
GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader | awk '{printf "%02d", $1}')



# do the genmon
echo "<icon>$ICON</icon><iconclick>xfce4-taskmanager</iconclick>"
echo "<text>c</text><bar>$CPU</bar>"
echo "<text>m</text><bar>$MEMUSAGE</bar>"
echo "<text>g</text><bar>$GPU_UTIL</bar>"
echo "<txt> $CPU | $MEMUSAGE | $GPU_UTIL </txt><txtclick>xfce4-taskmanager</txtclick>"
echo "<tool>=====CPU $CPULOAD=====
$TOPCPU
 
=====MEM: $MEMUSED of $MEMUSAGE2=====
$TOPMEM

=====GPU: $GPU_UTIL=====

 
=====HD usage: $HDUSED of $HDSIZE GB in use=====
$TOPHD</tool>"
exit 0
