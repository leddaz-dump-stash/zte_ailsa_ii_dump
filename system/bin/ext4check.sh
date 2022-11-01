#!/system/bin/sh

export PATH=/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin:/system/vendor/xbin
debug()
{
    #echo $1 > /dev/kmsg
}
reserved_5percent()
{
    local dev=$1
    local block_count=`/system/bin/tune2fs  -l $dev | grep "Block count:" | /system/bin/busybox awk '{print $3}'`
    debug "reserved_5percent bc:$block_count d:$dev p:$1"
    echo $(($block_count/100*5))
}

max_reserved()
{
    local dev=$1
    local block_size=`/system/bin/tune2fs  -l $dev | grep "Block size:" | /system/bin/busybox awk '{print $3}'`
    debug "max_reserved bs:$block_size d:$dev p:$1"
    echo $((200*1024*1024/$block_size))
}

reserved_size()
{
    local dev=$1
    local p5=`reserved_5percent $dev`
    max=`max_reserved $dev`
    debug "reserved_size m:$max p5:$p5 d:$dev p:$1"
    if busybox [ "$p5" -gt "$max" ] ; then
	p5=$max
    fi
    echo $p5
}

device=$3
echo "ext4check $device : ${device##*/} ${device%%[0-9]*}" > /dev/kmsg

if [ "${device%%[0-9]*}" == "/dev/block/dm-" ]
then
    /system/bin/e2fsck -p $3
    exit
fi

##ZTE_20150105_yeganlin,change the format tool,keeping the same with recovery process
if [ "${device##*/}" == "userdata" ]
then
    ##/system/bin/checkdata /system/bin/mke2fs -T ext4 -j -m 5 -b 4096 -L USERDATA $3
    /system/bin/checkdata $3 ${device##*/}
    case "$?" in
        0)  echo "format in checkdata"
	    dev=$3
	    size_to_reserve=`reserved_size $dev`
	    debug "size_to_reserve0 sr:$size_to_reserve d:$dev p:$3" 
            /system/bin/tune2fs -C 1 -r $size_to_reserve -u 1000 -g 9990 $3 
            ;;
        1)  echo "check success"
            /system/bin/tune2fs  -l $3 | grep "Reserved blocks gid" | grep 9990
            if [ $? -ne "0" ]; then
		dev=$3
		size_to_reserve=`reserved_size $dev`
		debug "size_to_reserve sr:$size_to_reserve d:$dev p:$3" 
                /system/bin/tune2fs -C 1 -r $size_to_reserve -u 1000 -g 9990 $3 
            fi
            ;;
    esac
    exit
fi
echo "ext4check $3" > /dev/kmsg
/system/bin/e2fsck -p $3
case "$?" in
   2) echo "need to reboot the phone"
   /system/bin/reboot	
   ;;
   
   8) echo "need to format the partition..."
#   /system/bin/mke2fs -T ext4 -j -m 0 -b 4096 -L $1 $3
   /system/bin/checkdata $3 ${device##*/}
#   /system/bin/tune2fs -j $1
   /system/bin/tune2fs -C 1 $3
   ;;
esac

# EXIT CODE for e2fsck: 
#     The exit code returned by e2fsck is the sum of the following conditions:
#       0    - No errors
#       1    - File system errors corrected
#       2    - File system errors corrected, system should be rebooted
#       4    - File system errors left uncorrected
#       8    - Operational error
#       16   - Usage or syntax error
#       32   - E2fsck canceled by user request
#       128  - Shared library error
