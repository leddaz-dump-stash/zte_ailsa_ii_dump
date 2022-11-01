#! /system/bin/sh
echo "$0 $@"

SSID=$1
KMGMT=$2
PSK=$3
ARGSNUM=$#
if ( test $ARGSNUM -gt 3 ); then
	STATICIP=$4
fi
BCM=`GetWiFiID | grep BCM`
WCNSS=`GetWiFiID | grep WCN`

SSID='"'$SSID'"'
PSK='"'$PSK'"'

cp -a /system/etc/wifi/wpa_supplicant.conf /data/misc/wifi/
chmod 0660 /data/misc/wifi/wpa_supplicant.conf
chown system.wifi /data/misc/wifi/wpa_supplicant.conf

if [ -n "$WCNSS" ] ; then
    insmod /system/lib/modules/wlan.ko > /data/pv_wificonnect.log 2>&1
    NUM=$?
    echo $NUM  >> /data/pv_wificonnect.log 2>&1
    if ( test $NUM -ne "0" ) ; then
        rmmod wlan.ko >> /data/pv_wificonnect.log 2>&1
        insmod /system/lib/modules/wlan.ko >> /data/pv_wificonnect.log 2>&1
    fi
fi

toybox ifconfig wlan0 up >> /data/pv_wificonnect.log 2>&1;

setprop ctl.start wpa_supplicant;
START=`getprop init.svc.wpa_supplicant`

sleep 1;

echo "before add_network" >> /data/pv_wificonnect.log 2>&1
NETWORK_ID=`wpa_cli -iwlan0 -p /data/misc/wifi/sockets add_network 0`
echo "network id: " >> /data/pv_wificonnect.log 2>&1
echo $NETWORK_ID >> /data/pv_wificonnect.log 2>&1
echo "after add_network" >> /data/pv_wificonnect.log 2>&1

if [ -n "$WCNSS" ]; then
    if ( test $ARGSNUM -lt 1 ) ; then
        echo "Too less args, please enter args!!!"  >> /data/pv_wificonnect.log 2>&1
    fi
    if ( test $ARGSNUM -eq 1 ) ; then
        echo "The $SSID network is open, are you sure without key_mgmt?"
        wpa_cli -iwlan0 -p /data/misc/wifi/sockets set_network $NETWORK_ID ssid $SSID >> /data/pv_wificonnect.log 2>&1;
    fi
    if ( test $ARGSNUM -ge 3 ) ; then
		wpa_cli -iwlan0 -p /data/misc/wifi/sockets set_network $NETWORK_ID ssid $SSID >> /data/pv_wificonnect.log 2>&1;

        wpa_cli -iwlan0 -p /data/misc/wifi/sockets set_network $NETWORK_ID key_mgmt "$KMGMT" >> /data/pv_wificonnect.log 2>&1;

        wpa_cli -iwlan0 -p /data/misc/wifi/sockets set_network $NETWORK_ID psk $PSK >> /data/pv_wificonnect.log 2>&1;
    fi
    #wpa_cli -iwlan0 -p /data/misc/wifi/sockets enable_network $NETWORK_ID >> /data/pv_wificonnect.log 2>&1
    wpa_cli -iwlan0 -p /data/misc/wifi/sockets select_network $NETWORK_ID >> /data/pv_wificonnect.log 2>&1
    wpa_cli -iwlan0 -p /data/misc/wifi/sockets reconnect >> /data/pv_wificonnect.log 2>&1

	wpa_cli -iwlan0 -p /data/misc/wifi/sockets status >> /data/pv_wificonnect.log 2>&1

    sleep 2;
fi

if [ -n "$BCM" ] ; then
    if ( test $ARGSNUM -lt 1 ) ; then
        echo "Too less args, please enter args!!!"  >> /data/pv_wificonnect.log 2>&1
    fi
    if ( test $ARGSNUM -eq 1 ) ; then
        echo "The $SSID network is open, are you sure without key_mgmt?"
        wpa_cli -iwlan0 -p /data/misc/wifi/sockets set_network $NETWORK_ID ssid "$SSID" >> /data/pv_wificonnect.log 2>&1
    fi

    if ( test $ARGSNUM -ge 3 ) ; then
        wpa_cli -iwlan0 set_network $NETWORK_ID ssid "$SSID" >> /data/pv_wificonnect.log 2>&1

        wpa_cli -iwlan0 set_network $NETWORK_ID key_mgmt "$KMGMT" >> /data/pv_wificonnect.log 2>&1

        wpa_cli -iwlan0 set_network $NETWORK_ID psk "$PSK" >> /data/pv_wificonnect.log 2>&1
    fi

    wpa_cli -iwlan0 enable_network $NETWORK_ID >> /data/pv_wificonnect.log 2>&1
	wpa_cli -iwlan0 status >> /data/pv_wificonnect.log 2>&1
    STATUS=`wpa_cli -iwlan0 status | toybox grep 'wpa_state=COMPLETED'`
    while [ -z "$STATUS" ] ; do
        echo "STATUS is empty!!"  >> /data/pv_wificonnect.log 2>&1
        sleep 1
        STATUS=`wpa_cli -iwlan0 status | toybox grep 'wpa_state=COMPLETED'`
    done
fi

if ( test $ARGSNUM -eq 3 ) ; then
	dhcpcd wlan0  >> /data/pv_wificonnect.log 2>&1;
	sleep 1
	IP=`toybox ifconfig | toybox grep '192.168'`
	while [  -z "$IP" ] ; do
#		dhcpcd wlan0  >> /data/pv_wificonnect.log
		sleep 1
		IP=`toybox ifconfig | toybox grep '192.168'`
	done
fi

if ( test $ARGSNUM -gt 3 ) ; then
	echo static ip distributing!  >> /data/pv_wificonnect.log 2>&1
	#toybox ifconfig wlan0 192.168.1.$STATICIP netmark 255.255.255.0
	toybox ifconfig wlan0 192.168.1.$STATICIP netmask 255.255.255.0 >> /data/pv_wificonnect.log 2>&1
	toybox route add default gw 192.168.1.1 >> /data/pv_wificonnect.log 2>&1
	ping -c 5 192.168.1.1 >> /data/pv_wificonnect.log 2>&1
	IP=`toybox ifconfig | toybox grep '192.168'`
	while [  -z "$IP" ] ; do
		sleep 1;
		IP=`toybox ifconfig | toybox grep '192.168'`
	done
fi

toybox ifconfig wlan0  >> /data/pv_wificonnect.log 2>&1
wpa_cli -iwlan0 -p /data/misc/wifi/sockets status >> /data/pv_wificonnect.log 2>&1
echo "Have conneted to ssid $SSID,"  >> /data/pv_wificonnect.log 2>&1

