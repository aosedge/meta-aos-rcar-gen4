FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://domd-set-root \
"

FILES_${PN} += " \
    ${libdir}/xen/bin/domd-set-root \
    ${libdir}/xen/boot/initramfs-domd \
"

RDEPENDS_${PN} += " \
    guestreboot \
"

do_install_append() {
    # Install domd-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domd-set-root ${D}${libdir}/xen/bin

    # Call domd-set-root script
    echo "[Service]" >> ${D}${systemd_system_unitdir}/domd.service
    echo "ExecStartPre=${libdir}/xen/bin/domd-set-root" >> ${D}${systemd_system_unitdir}/domd.service

    # Add guest reboot dependency
    echo "[Unit]" >> ${D}${systemd_system_unitdir}/domd.service
    echo "Wants=guestreboot@DomD.service" >> ${D}${systemd_system_unitdir}/domd.service
    echo "Before=guestreboot@DomD.service" >> ${D}${systemd_system_unitdir}/domd.service

    # Install domd initramfs
    install -m 0644 ${S}/core-image-tiny-initramfs-spider.cpio.gz ${D}${libdir}/xen/boot/initramfs-domd
}
