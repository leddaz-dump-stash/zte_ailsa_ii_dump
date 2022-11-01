#!/system/bin/sh

#local funi=1
while true
do
	date >> /cache/logs/logcat/mem.txt
	procrank | busybox head -10 >> /cache/logs/logcat/mem.txt
	sleep 600
done
