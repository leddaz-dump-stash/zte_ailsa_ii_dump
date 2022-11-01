#!/system/bin/sh
sleep 120
busybox ls -i -l -R /system > /cache/logs/logcat/hotfile.system.txt
busybox ls -i -l -R /data > /cache/logs/logcat/hotfile.data.txt
top -m 8 -d 180 -t >> /cache/logs/logcat/cpu.txt&
while true
do
sleep 180
#busybox top -d 60 -n 10 1>>/cache/logs/logcat/cpu.txt
#cat /proc/msm_pm_stats >>$logfile
l=`busybox du -s  /cache/logs//logcat/trace.0 | busybox awk '{print $1}'`
if busybox [ "$l" -gt "4096" ] ;then
    busybox rm -fr /cache/logs/logcat/trace.5.tar.gz
    busybox mv /cache/logs/logcat/trace.4.gz /cache/logs/logcat/trace.5.gz
    busybox mv /cache/logs/logcat/trace.3.gz /cache/logs/logcat/trace.4.gz
    busybox mv /cache/logs/logcat/trace.2.gz /cache/logs/logcat/trace.3.gz
    busybox mv /cache/logs/logcat/trace.1.gz /cache/logs/logcat/trace.2.gz
    cd /cache/logs/logcat/
    busybox tar zcf /cache/logs/logcat/trace.1.gz trace.0
    echo "" > /cache/logs/logcat/trace.0
    sync
fi
date >> /cache/logs/logcat/cpu.txt
done
