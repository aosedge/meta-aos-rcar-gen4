SUMMARY = "Aos image for Renesas RCAR devices"

require recipes-core/images/rcar-image-minimal.bb
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
    xen-network \
    dnsmasq \
    openssh \
"

IMAGE_INSTALL += " iproute2 iproute2-tc tcpdump nvme-cli"

IMAGE_INSTALL += " kernel-module-nvme-core kernel-module-nvme"

IMAGE_INSTALL += " kernel-module-ixgbe"

IMAGE_INSTALL += " e2fsprogs"

IMAGE_INSTALL += " aos-messageproxy"

# Set fixed rootfs size
IMAGE_ROOTFS_SIZE ?= "1048576"
IMAGE_OVERHEAD_FACTOR ?= "1.0"
IMAGE_ROOTFS_EXTRA_SPACE ?= "524288"
