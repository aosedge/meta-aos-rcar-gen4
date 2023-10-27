require optee-os.inc

libdir[unexport] = "1"

EXTRA_OEMAKE += " \
    CFG_PKCS11_TA_HEAP_SIZE="(256 * 1024)" \
"

FILES:${PN} += " \
    ${nonarch_base_libdir} \
"

do_install() {
    # install pkcs11 TA
    install -d ${D}${nonarch_base_libdir}/optee_armtz/
    install -p -m 0444 ${S}/out/arm-plat-${PLATFORM}/ta/pkcs11/*.ta ${D}${nonarch_base_libdir}/optee_armtz/
}
