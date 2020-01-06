#!/bin/bash

###
 # @Description: 制作文件系统镜像
 # @Version: 1.0
 # @Autor: lhgcs
 # @Date: 2020-01-02 11:13:08
 # @LastEditors  : lhgcs
 # @LastEditTime : 2020-01-02 14:48:19
 ###

USER="rock"
IP="192.168.10.84"

tempdir=temp_$(date +%Y-%m-%d)
if [ ! -d ${tempdir} ]
then
    mkdir ${tempdir}
fi
cd ${tempdir}

# sudo apt-get install rsync

# 镜像名称
rootfs_img=rootfs.img
# 挂载路径
img_mount_dir="img_mount"

echo "create empty image"
# 制作镜像，6G
if [ ! -f ${rootfs_img} ]
then
    dd if=/dev/zero of=${rootfs_img} bs=1M count=6144
fi

echo "format image"
# 格式化镜像文件，并加入linuxroot卷标
# sudo mkfs.ext4 -F -L linuxroot ${rootfs_img}
# sudo mkfs.ext4 -L EXT4 ${rootfs_img}
sudo /sbin/mkfs.ext4 ${rootfs_img}
# sudo mkfs -t ext4 -c ${rootfs_img}

echo "mount image"
# 挂载镜像
if [ ! -d ${img_mount_dir} ]
then
    mkdir ${img_mount_dir}
fi

sudo umount ${img_mount_dir}
sudo mount ${rootfs_img} ${img_mount_dir}

echo "sync rootfs"
# 复制文件系统到PC
if [ ! -d rock_rootfs ]
then
    mkdir rock_rootfs
fi
sudo rsync -avz ${USER}@${IP}:/ rock_rootfs/
sudo rsync -a rock_rootfs/ ${img_mount_dir}/
# sudo cp -rfp

echo "unmount image"
# 卸载镜像
sudo umount ${img_mount_dir}

# 检查并修复${rootfs_img}镜像的文件系统
# e2fsck -p -f ${rootfs_img}。
# 精简镜像文件大小
# resize2fs -M ${rootfs_img}

# ./build/mk-image.sh -c rk3399 -t system -r rootfs.img
