function executesnapshot()
{
echo "####################################################################"  >> $SNAPSHOTPATH
echo "###-------------[$1]---------------###"  >> $SNAPSHOTPATH
echo "####################################################################"  >> $SNAPSHOTPATH
$1 >> $SNAPSHOTPATH 
echo ""  >> $SNAPSHOTPATH
}

SNAPSHOTPATH="/cache/logs/snapshotwhenpull.txt"
echo "=================ADB-PULL-SNAP-SHOT-START========================" > $SNAPSHOTPATH
date  >> $SNAPSHOTPATH
executesnapshot "getprop"
executesnapshot "ps -t"
executesnapshot "dumpsys batterystats"
executesnapshot "dumpsys SurfaceFlinger"
executesnapshot "dumpsys sensorservice"
executesnapshot "dmesg"
