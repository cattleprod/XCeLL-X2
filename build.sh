#!/bin/bash

# Set Default Path
TOP_DIR=$PWD
KERNEL_PATH=/home/nightwatch/android/kernel/XCeLL-X2

# TODO: Set toolchain and root filesystem path
TAR_NAME=zImage.tar

TOOLCHAIN="/home/nightwatch/android/toolchain/4.7/android-toolchain-eabi/bin/arm-eabi-"
# TOOLCHAIN="/home/neophyte-x360/toolchain/bin/arm-none-eabi-"
ROOTFS_PATH="/home/nightwatch/android/initramfs/ics-miui-initramfs/"

export USE_SEC_FIPS_MODE=true

echo "Cleaning latest build"
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j`grep 'processor' /proc/cpuinfo | wc -l` clean

cp -f $KERNEL_PATH/arch/arm/configs/XCeLL_defconfig $KERNEL_PATH/.config

make -j4 -C $KERNEL_PATH xconfig || exit -1
make -j4 -C $KERNEL_PATH ARCH=arm CROSS_COMPILE=$TOOLCHAIN || exit -1

cp drivers/net/wireless/bcmdhd/dhd.ko $ROOTFS_PATH/lib/modules/
cp drivers/samsung/j4fs/j4fs.ko $ROOTFS_PATH/lib/modules/
cp drivers/samsung/fm_si4709/Si4709_driver.ko $ROOTFS_PATH/lib/modules/
cp drivers/scsi/scsi_wait_scan.ko $ROOTFS_PATH/lib/modules/
cp drivers/staging/android/logger.ko $ROOTFS_PATH/lib/modules/
cp fs/cifs/cifs.ko $ROOTFS_PATH/lib/modules/
cp fs/fuse/fuse.ko $ROOTFS_PATH/lib/modules/

make -j4 -C $KERNEL_PATH ARCH=arm CROSS_COMPILE=$TOOLCHAIN || exit -1

# Copy Kernel Image
cp -f $KERNEL_PATH/arch/arm/boot/zImage .

cd arch/arm/boot
tar cf $KERNEL_PATH/arch/arm/boot/$TAR_NAME zImage && ls -lh $TAR_NAME
