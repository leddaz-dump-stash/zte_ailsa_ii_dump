#!/system/bin/sh
local cpufile=//cache/logs/logcat/summary/cpu.txt
local usagefile=//cache/logs/logcat/summary/usage.txt
local memfile=//cache/logs/logcat/summary/mem.txt
local jankfile=//cache/logs/logcat/summary/jank.txt

if [ "x$(getprop persist.sys.ztelog.enable)" != "x1" ]; then
    exit 0
fi

chown system:system /cache/logs/logcat/summary

dumpsys usagestats flushall

date >> $usagefile
date >> $cpufile
date >> $jankfile
date >> $memfile

cat /data/system/screen_on_time >> $cpufile
show_cpu.sh >> $cpufile
grep "package name" /data/system/packages.xml >> $cpufile

dumpsys graphicsstats >> $jankfile
dumpsys procstats --hours 24 >> $memfile

grep "Displayed" /cache/logs/logcat/logcat_am.txt >> $usagefile

#dumpsys usagestats clearall
