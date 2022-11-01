#!/system/bin/sh
#this .sh is used to test current while devices enter LPM in FTM

#how to run this .sh
#adb push ftmlpm.sh /data/
#adb shell
#cd /data
#chmod 777 ftmlpm.sh
#./ftmlpm.sh
echo 0 > /sys/class/leds/lcd-backlight/brightness
echo 4 > /sys/class/graphics/fb0/blank
echo mmi > /sys/power/wake_unlock
echo mem > /sys/power/autosleep


