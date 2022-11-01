#!/system/bin/sh

#case "$emmc_boot"
#    in "true")
#
#    ;;
#esac
#if [ "x$(getprop persist.sys.ztelog.enable)" != "x1" ]; then
#        exit 0
#fi
################################################################33 0x800000
echo 0 > /sys/kernel/debug/tracing/events/mmc/mmc_blk_rw_summary/enable
echo 0 > /sys/kernel/debug/tracing/events/mmc/mmc_pid_blk_read_summary/enable
echo 0 > /sys/kernel/debug/tracing/events/mmc/mmc_pid_blk_write_summary/enable
echo 0 > /sys/kernel/debug/tracing/events/sched/sched_delay_wait_memory_io/enable
echo 0 > /sys/kernel/debug/tracing/events/sched/sched_delay_wait_swap_io/enable
echo 0 > /sys/kernel/debug/tracing/events/sched/sched_cpuwait_summary/enable
echo 0 > /sys/kernel/debug/tracing/events/sched/sched_iowait_summary/enable
echo 0 > /sys/kernel/debug/tracing/events/filemap/mm_filemap_file_io_count/enable
echo 0 > /sys/kernel/debug/tracing/events/sched/sched_cpuusage_summary/enable
busybox killall start_tracer.sh
exit 1

