FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
FILESEXTRAPATHS:prepend:aos-main-node := "${THISDIR}/files/main-node:"
FILESEXTRAPATHS:prepend:aos-secondary-node := "${THISDIR}/files/secondary-node:"


SRC_URI += " \
    file://systemd-networkd-wait-online.conf \
    file://interface-forward-systemd-networkd.conf \
    file://tsn0.network \
    file://tsn1.network \
    file://vmq0.network \
"

FILES:${PN} += " \
    ${sysconfdir}/systemd/network \
    ${sysconfdir}/systemd/system/systemd-networkd.service.d \
"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/
    install -m 0644 ${S}/interface-forward-systemd-networkd.conf ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d
    mv ${D}${sysconfdir}/systemd/network/tsn0.network ${D}${sysconfdir}/systemd/network/10-tsn0.network
    mv ${D}${sysconfdir}/systemd/network/tsn1.network ${D}${sysconfdir}/systemd/network/10-tsn1.network
}
