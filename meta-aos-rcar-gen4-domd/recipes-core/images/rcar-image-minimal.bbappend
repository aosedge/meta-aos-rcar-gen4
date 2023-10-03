require recipes-core/images/aos-image.inc

IMAGE_INSTALL += " \
    pciutils \
    devmem2 \
    iccom-support \
    optee-test \
"

IMAGE_INSTALL += " \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-tools-pcid \
    xen-network \
    dnsmasq \
"

IMAGE_INSTALL += " iproute2 iproute2-tc tcpdump nvme-cli"

IMAGE_INSTALL += " kernel-module-nvme-core kernel-module-nvme"

IMAGE_INSTALL += " kernel-module-ixgbe"

IMAGE_INSTALL += " e2fsprogs"


# Set fixed rootfs size
IMAGE_ROOTFS_SIZE = "1048576"
IMAGE_OVERHEAD_FACTOR = "1.0"
IMAGE_ROOTFS_EXTRA_SPACE = "0"
