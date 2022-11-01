#!/system/bin/sh

echo "start diag_mdlog" > /cache/op_logs.txt
chmod 777 /system/bin/diag_mdlog
/system/bin/diag_mdlog -n 40 &
