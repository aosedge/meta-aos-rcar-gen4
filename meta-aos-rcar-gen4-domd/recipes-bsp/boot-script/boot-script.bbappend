FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = " \
    file://boot.cmd \
"
do_compile() {
    uboot-mkimage -T script -d ${WORKDIR}/boot.cmd ${B}/boot.uImage
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${B}/boot.uImage ${DEPLOYDIR}/boot.uImage
}
