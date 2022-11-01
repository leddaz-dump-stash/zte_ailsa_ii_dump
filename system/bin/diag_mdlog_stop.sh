#!/system/bin/sh
PATH=$PATH:/system/vendor/xbin/

echo "start diag_mdlog" > /cache/op_logs.txt
busybox pkill -SIGINT diag_mdlog
