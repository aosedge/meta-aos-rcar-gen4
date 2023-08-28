require recipes-core/images/aos-image.inc

# System components
IMAGE_INSTALL_append = " \
    openssh \
    iperf3 \
    snort \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-tools-pcid \
    xen-network \
    dnsmasq \
    pciutils \
    devmem2 \
    iccom-support \
    optee-test \
    block \
    iputils \
    iproute2 \
    iproute2-tc \
    tcpdump \
    nvme-cli \
    kernel-module-nvme-core \
    kernel-module-nvme \
    kernel-module-ixgbe \
    e2fsprogs \
    aos-messageproxy \
"

AOS_ROOTFS_IMAGE_VERSION = "${AOS_DOMD_IMAGE_VERSION}"

IMAGE_POSTPROCESS_COMMAND += "create_boot_version;"

create_boot_version() {
    install -d ${DEPLOY_DIR_IMAGE}/dom0/aos
    echo "VERSION=\"${AOS_DOM0_IMAGE_VERSION}\"" > ${DEPLOY_DIR_IMAGE}/dom0/aos/version
}
