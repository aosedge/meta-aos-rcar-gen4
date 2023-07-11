IMAGE_NAME = "initramfs-${XT_DOM_NAME}"

AOS_INITRAMFS_SCRIPTS += " \
    initramfs-module-lvm \
    initramfs-module-nfsrootfs \
    initramfs-module-opendisk \
    initramfs-module-rundir \
    lvm2 \
"
