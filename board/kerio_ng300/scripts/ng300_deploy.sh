#!/bin/bash

DEVICE=$1
if [ -z ${DEVICE} ]
then
    echo "usage: ng300_deploy.sh DEVICE"
    echo "DEVICE is the device to deploy to, eg: /dev/sda."
    exit 1
fi

echo "This will DESTROY all data on ${DEVICE} and install the Nifty Router firmware."
read -p "Are you sure you want to continue [y/N]? " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

BASE_DIR=$(realpath $(dirname $(readlink -f $0))/../../..)
IMAGE_DIR=${BASE_DIR}/output/images

cat << EOF | sfdisk -q ${DEVICE}
label: dos
start=1M,size=64M,bootable,type=linux
size=512M,type=linux
size=512M,type=linux
type=linux
EOF

p=`ls ${DEVICE}*1 | sed -e "s|${DEVICE}\(.*\)1|\1|"`

mkfs.ext2 -qF ${DEVICE}${p}1 -L boot
mkfs.ext2 -qF ${DEVICE}${p}2 -L root
mkfs.ext2 -qF ${DEVICE}${p}3 -L root
mkfs.ext4 -qF ${DEVICE}${p}4 -L data

MOUNT=$(mktemp -d)

# Extract the root filesystem(s)
for root in ${DEVICE}${p}2 ${DEVICE}${p}3
do
    mount ${root} ${MOUNT}
    tar -xf ${IMAGE_DIR}/rootfs.tar --exclude "./boot/*" --exclude "./var/*" -C ${MOUNT}
    umount ${MOUNT}
done

#Extract the var filesystem
mount ${DEVICE}${p}4 ${MOUNT}
tar -xf ${IMAGE_DIR}/rootfs.tar --strip-components=2 -C ${MOUNT} ./var

#Set the admin password and authorized keys
MKPASSWD=${BASE_DIR}/output/host/bin/mkpasswd
if [ -z "${ADMIN_PASSWD}" ]; then
        ADMIN_PASSWD=`tr -dc 'A-Za-z0-9~!@#$%^&*()=+;:",.<>?|' < /dev/urandom | head -c 16`
fi
ADMIN_ENC_PASSWD="`$MKPASSWD -m sha-256 "$ADMIN_PASSWD"`"
sed -e "s,^admin:[^:]*:,admin:${ADMIN_ENC_PASSWD}:," -i ${MOUNT}/etc/shadow
echo "Admin password: ${ADMIN_PASSWD}"

#set any admin public keys
for key in ${ADMIN_PUBKEY}; do
        cat $key >> ${MOUNT}/home/admin/.ssh/authorized_keys
done

umount ${MOUNT}

# Extract the boot filesystem
mount ${DEVICE}${p}1 ${MOUNT}
tar -xf ${IMAGE_DIR}/rootfs.tar --strip-components=2 -C ${MOUNT} ./boot

# Copy the kernel
cp ${IMAGE_DIR}/bzImage ${MOUNT}/linux-current
cp ${IMAGE_DIR}/bzImage ${MOUNT}/linux-prev

# Install grub
${BASE_DIR}/output/host/sbin/grub-install --boot-directory=${MOUNT} --target=i386-pc ${DEVICE}

umount ${MOUNT}
rmdir ${MOUNT}

