#!/bin/sh
MOUNTPOINT="/tmp/config"
BOOT_CONF=`/bin/cat /etc/default_config/BOOT.conf 2>/dev/null`
CONFIG_DEV_NODE=`/sbin/getcfg "CONFIG STORAGE" DEVICE_NODE -f /etc/platform.conf`
CONFIG_DEV_PART=`/sbin/getcfg "CONFIG STORAGE" FS_ACTIVE_PARTITION -f /etc/platform.conf`
CONFIG_DEV_FS=`/sbin/getcfg "CONFIG STORAGE" FS_TYPE -f /etc/platform.conf`

# check if the HAL subsystem exist
if [ -x /sbin/hal_app ]; then
    BOOT_DEV=$(/sbin/hal_app --get_boot_pd port_id=0)
elif [ "x${BOOT_CONF}" = "xTS-NASARM" ]; then
        BOOT_DEV="/dev/mtdblock"
else
    BOOT_DEV="/dev/sdx"
fi

if [ "x$CONFIG_DEV_NODE" != "x" ]; then
    DEV_NAS_CONFIG=${CONFIG_DEV_NODE}${CONFIG_DEV_PART}
elif [ "x${BOOT_CONF}" = "xTS-NASARM" ]; then
    DEV_NAS_CONFIG=${BOOT_DEV}5
else
    DEV_NAS_CONFIG=${BOOT_DEV}6
fi
EXPR="/usr/bin/expr"

mount_config_dev() {
[ -d $MOUNTPOINT ] || /bin/mkdir $MOUNTPOINT
if [ "x$CONFIG_DEV_NODE" != "x" ]; then
        if [ "x$CONFIG_DEV_FS" = "xubifs" ]; then
                /sbin/ubiattach -m $CONFIG_DEV_PART -d 2
                /bin/mount -t ubifs ubi2:config $MOUNTPOINT > /dev/null 2>&1
        else
                return 0
        fi
else
        /bin/mount $DEV_NAS_CONFIG -t ext2 $MOUNTPOINT > /dev/null 2>&1
fi
[ $? = 0 ] || /bin/echo "$0: mount $DEV_NAS_CONFIG failed."
}

umount_config_dev() {
CNT=0
while [ $CNT -lt 5 ]; do
        if [ "x$CONFIG_DEV_NODE" != "x" ]; then
                if [ "x$CONFIG_DEV_FS" = "xubifs" ]; then
                        /bin/umount /tmp/config
                        /sbin/ubidetach -m $CONFIG_DEV_PART
                else
                        break;
                fi
        else
                /bin/umount $DEV_NAS_CONFIG 2>/dev/null
        fi
        if [ $? = 0 ]; then
                break;
        fi
        sleep 1
        CNT=`expr $CNT + 1`
done
[ $? = 0 ] || /bin/echo "$0: umount $DEV_NAS_CONFIG failed."
}

case "$1" in
  mount_cfg)
                mount_config_dev
                exit 0
        ;;
  umount_cfg)
                umount_config_dev
                exit 0
        ;;
  *)
  echo Usage: "$0 [mount_cfg|umount_cfg]"
esac