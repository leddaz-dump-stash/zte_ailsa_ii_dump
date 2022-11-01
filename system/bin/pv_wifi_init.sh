#! /system/bin/sh

cp -a /vendor/etc/wifi/wpa_supplicant.conf /data/misc/wifi/
cp /vendor/etc/wifi/p2p_supplicant_overlay.conf /data/misc/wifi/p2p_supplicant.conf
chmod 0777 /data/misc/wifi/wpa_supplicant.conf
chmod 0777 /data/misc/wifi/p2p_supplicant.conf

insmod /vendor/lib/modules/wlan.ko
NUM=$?
echo $NUM
if ( test $NUM -ne "0" ) ; then
    rmmod wlan.ko
    insmod /vendor/lib/modules/wlan.ko
fi

toybox ifconfig wlan0 up

setprop ctl.start wpa_supplicant
getprop init.svc.wpa_supplicant
sleep 1
