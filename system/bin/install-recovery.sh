#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/bootdevice/by-name/recovery:18916654:35d2b9553cb9fd44040a3eda6c3cc6b45dc6692d; then
  applypatch -b /system/etc/recovery-resource.dat EMMC:/dev/block/bootdevice/by-name/boot:16016682:06fe1b24709e9f590bc9796ae64cb05cf05f181a EMMC:/dev/block/bootdevice/by-name/recovery 35d2b9553cb9fd44040a3eda6c3cc6b45dc6692d 18916654 06fe1b24709e9f590bc9796ae64cb05cf05f181a:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
