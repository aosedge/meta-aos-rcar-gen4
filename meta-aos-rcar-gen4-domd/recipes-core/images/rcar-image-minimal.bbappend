require recipes-core/images/aos-image.inc

# System components
IMAGE_INSTALL_append = " \
    devmem2 \
    iccom-support \
    pciutils \
    optee-test \
    openssh \
    iperf3 \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-tools-pcid \
    xen-network \
    dnsmasq \
    block \
    iputils \
    aos-messageproxy \
"

IMAGE_INSTALL_append = " iproute2 iproute2-tc tcpdump nvme-cli"

IMAGE_INSTALL_append = " kernel-module-nvme-core kernel-module-nvme"

IMAGE_INSTALL_append = " kernel-module-ixgbe"

IMAGE_INSTALL_append = " e2fsprogs"

AOS_ROOTFS_IMAGE_VERSION = "${AOS_DOMD_IMAGE_VERSION}"

IMAGE_POSTPROCESS_COMMAND += "create_boot_version;"

create_boot_version() {
    install -d ${DEPLOY_DIR_IMAGE}/dom0/aos
    echo "VERSION=\"${AOS_DOM0_IMAGE_VERSION}\"" > ${DEPLOY_DIR_IMAGE}/dom0/aos/version
}
