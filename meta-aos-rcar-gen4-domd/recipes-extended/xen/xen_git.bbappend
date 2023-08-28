FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

require xen-source.inc

# We are dropping TUNE_CCARGS from for Xen because it won't build for armv8.2, as
# it conflicts with -mcpu=generic provided by own Xen build system
HOST_CC_ARCH_remove="-march=armv8.2-a+crypto"
HOST_CC_ARCH_remove="-mcpu=cortex-a55"

DEPENDS += "u-boot-mkimage-native"

do_deploy_append () {
    if [ -f ${D}/boot/xen ]; then
        uboot-mkimage -A arm64 -C none -T kernel -a 0x78080000 -e 0x78080000 -n "XEN" -d ${D}/boot/xen ${DEPLOYDIR}/xen-${MACHINE}.uImage
        ln -sfr ${DEPLOYDIR}/xen-${MACHINE}.uImage ${DEPLOYDIR}/xen-uImage
    fi
}

SRC_URI_append_spider = " \
    file://early_printk_spider.cfg \
"

do_configure_append() {
    # merge configuration fragments manually using kconfig's native facilities
    ${S}/xen/tools/kconfig/merge_config.sh -m -O ${B}/xen ${B}/xen/.config ${WORKDIR}/*.cfg
}
