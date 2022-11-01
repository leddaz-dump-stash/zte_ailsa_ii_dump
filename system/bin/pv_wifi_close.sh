#! /system/bin/sh
#diag_socket_log -k

#BCM=`GetWiFiID | grep BCM`
#WCNSS=`GetWiFiID | grep WCN`

STATE=`getprop init.svc.wpa_supplicant`
echo "wifi disconnect:000 state=$STATE"
while [ test $STATE -ne "stopped" ]; do
	setprop ctl.stop wpa_supplicant
	STATE=`getprop init.svc.wpa_supplicant`
	echo "wifi disconnect:111 state=$STATE"
done

#if [ -n "$WCNSS" ]; then
toybox ifconfig wlan0 down
rmmod wlan.ko
echo "wifi disconnect success"
#fi
