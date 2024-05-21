require optee.inc

EXTRA_OEMAKE += " \
    CFG_NS_VIRTUALIZATION=y \
    CFG_VIRT_GUEST_COUNT=3 \
    CFG_PKCS11_TA_HEAP_SIZE="(256 * 1024)" \
"

do_install:append() {
    install -m 644 ${B}/core/tee.srec ${D}${nonarch_base_libdir}/firmware/tee.srec
}

TA_PKCS11_UUID = "fd02c9da-306c-48c7-a49c-bbd827ae86ee"

do_deploy:append(){
    install -d ${DEPLOYDIR}
    ln -sfr ${DEPLOYDIR}/${MLPREFIX}optee/tee.srec ${DEPLOYDIR}/tee-${MACHINE}.srec
    ln -sfr ${DEPLOYDIR}/${MLPREFIX}optee/tee-raw.bin ${DEPLOYDIR}/tee-${MACHINE}.bin

    install -d ${DEPLOYDIR}/aos/ta
    install -m 0644 ${B}/ta/pkcs11/${TA_PKCS11_UUID}.ta ${DEPLOYDIR}/aos/ta
}
