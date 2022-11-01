#!/system/bin/sh

# Don't enable systrace when the total memory is below 800MB
local mem_total=`cat /proc/meminfo | grep MemTotal | busybox awk '{print $2}'`
if busybox [ $mem_total -lt 800000 ]; then
    echo "dumptracer.sh exit becasue mem_total = $mem_total"
    exit 0
fi

systracing_is_running=`cat /d/tracing/tracing_on`
if busybox [ "$systracing_is_running" -eq "0" ]; then
    exit 0
fi
echo 500 > /sys/class/timed_output/vibrator/enable

local tt=`date +%G%m%d_%H%M%S`
local mm=`getprop debug.systrace.reason`
local mmm=${mm/\//\.}
local file=/cache/logs/logcat/trace.${tt}.${mmm}.txt
cd /cache/logs/logcat/

#getenforce|grep Enforcing

#if busybox [ $? -eq 0 ]; then
#    echo "enforceing..."
#cat /d/tracing/trace > $file
#else
#    atrace -c -b 8192 -t 3600000 gfx wm view webview mdss am res app sched freq dalvik input message binder action memreclaim --async_dump -z -o $file
#fi
atrace2 -c -b 8192 -t 3600000 gfx wm view webview mdss am res app sched freq dalvik input message binder action memreclaim --async_dump -z -o $file

logcat -b events -d > events.txt
logcat -d > mainsystem.txt
busybox tar zcf $file.tar.gz $file events.txt mainsystem.txt
busybox rm -fr $file events.txt mainsystem.txt
mkdir /sdcard/systrace/

funi=0
for file in `ls /cache/logs/logcat/trace.*.gz | busybox sort -nr`
do
funi=`busybox expr $funi + 1`
if [ "$funi" -gt "3" ]; then
  mv $file /sdcard/systrace/
  echo $file
fi
done

funi=0
for file in `ls /sdcard/systrace/trace.*.gz | busybox sort -nr`
do
funi=`busybox expr $funi + 1`
if [ "$funi" -gt "60" ]; then
  rm -fr $file
  echo $file
fi
done

setprop debug.systrace.reason ""
echo 500 > /sys/class/timed_output/vibrator/enable
