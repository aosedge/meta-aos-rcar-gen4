
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://nvme.service \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "nvme.service"

FILES:${PN} += " \
    ${systemd_system_unitdir} \
"

pkg_postinst_ontarget:${PN}() {
}

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/nvme.service ${D}${systemd_system_unitdir}
}
