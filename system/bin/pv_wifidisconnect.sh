#! /system/bin/sh
#diag_socket_log -k

#BCM=`GetWiFiID | grep BCM`
WCNSS=`GetWiFiID | grep WCN`
STATE=`getprop init.svc.wpa_supplicant`
while ( test $STATE -ne "stopped" ) do
	setprop ctl.stop pvwpa_supplicant
	STATE=`getprop init.svc.wpa_supplicant`
done

if [ -n "$WCNSS" ]; then
rmmod wlan.ko
fi

