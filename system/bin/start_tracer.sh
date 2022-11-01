#!/system/bin/sh

#add busybox path to system env PATH
PATH=$PATH:/system/vendor/xbin/

function exit_if_ok()
{
    l=`busybox du -s  "/cache/logs/logcat/trace.0" | busybox awk '{print $1}'`
    if busybox [ "$l" -gt 10 ]; then
        echo $?
        echo $tt >> /cache/logs/logcat/baseinfo.txt
        echo 1000 > /sys/class/timed_output/vibrator/enable
        exit 0
    fi
}

function start_atrace()
{
    echo "try $1"
#    echo kgsl:* >> /d/tracing/set_event
    /system/bin/atrace2 -b $1 -t10 mdss app res webview message dalvik freq am input view sched load wm gfx memreclaim binder pagecache -z > /cache/logs/logcat/trace.0
    exit_if_ok
}

function start_persist_atrace()
{
#    supolicy --live "allow tracer system_file:file entrypoint;"
    /system/bin/atrace2 -c -b 4096 -t3600000 gfx wm view webview mdss am res app sched freq dalvik input binder action memreclaim workq irq mmc disk --async_start
}


if [ "x$(getprop persist.sys.ztelog.enable)" != "x1" ]; then
    exit 0
fi

################################################################
# Don't enable systrace when the total memory is below 800MB
local mem_total=`cat /proc/meminfo | grep MemTotal | busybox awk '{print $2}'`
if busybox [ $mem_total -lt 800000 ]; then
    echo "start_tracer.sh exit becasue mem_total = $mem_total"
    exit 0
fi

echo 4096 > /d/tracing/saved_cmdlines_size

local getsystrace=`getprop init.svc.getsystrace`
local systracing_is_running=`cat /d/tracing/tracing_on`
if busybox [ "$getsystrace" != "running" ]; then
    if busybox [ "$systracing_is_running" -eq "0" ]; then
        setprop sys.check.interval 500
        start_persist_atrace
        exit 0
    fi
fi

if busybox [ "$systracing_is_running" -eq "1" ]; then
    start dumpsystrace
    exit 0
fi

local tt=`date +%G%m%d_%H%M%S`
#echo 1000 > /sys/class/timed_output/vibrator/enable
#start_atrace 10240
#start_atrace 8192
#start_atrace 6000
#start_atrace 4096
#start_atrace 3072
