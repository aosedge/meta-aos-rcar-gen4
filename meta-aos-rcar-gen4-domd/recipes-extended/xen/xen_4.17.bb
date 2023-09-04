# stable-4.17 status on 5/26/2023

PV = "${XEN_REL}+stable${SRCPV}"

S = "${WORKDIR}/git"

require xen.inc
require xen-hypervisor.inc

TOOLCHAIN = "gcc"
LDFLAGS:remove = "-fuse-ld=lld"

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
    oe_runmake xt_defconfig
}
