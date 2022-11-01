#! /system/bin/sh

#CONFIG_PATH=/system/etc/tki_config.ini
CONFIG_PATH=$4

toybox dos2unix $CONFIG_PATH

LINE_NUMS=`toybox sed -n "$=" $CONFIG_PATH`
FIELD_LINNUM=`toybox sed "/$1/"q $CONFIG_PATH | toybox sed -n "$="`
TEMP=`toybox sed -n "$FIELD_LINNUM,/$2/"p $CONFIG_PATH | toybox sed -n "$="`

PARAM_LINNUM=$((FIELD_LINNUM+TEMP-1))

if [ $FIELD_LINNUM -eq $LINE_NUMS ]; then
	echo "Can not find the field $1"
	exit
fi

if [ $PARAM_LINNUM -eq $LINE_NUMS ] || [ $TEMP -gt 5 -a $1 != "MMI" ]; then
	echo "Can not find the parameter $2, add parameter."
	toybox sed -i "$((FIELD_LINNUM))a$2=$3" $CONFIG_PATH
else
	echo "Parameter $2 found, modify the value."
	toybox sed -i "$((PARAM_LINNUM))s/^$2=.*/$2=$3/" $CONFIG_PATH
fi

toybox unix2dos $CONFIG_PATH
