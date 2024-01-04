FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

BRANCH = "develop"
SRCREV = "769ef62fdc96347749d5786e8f7159dbe5771610"

SRC_URI += " \
    file://optee-identity.conf \
"

FILES:${PN} += " \
    ${sysconfdir} \
"

# Base layer for services
RDEPENDS:${PN} += " \
    python3 \
    python3-core \
"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -m 0644 ${WORKDIR}/optee-identity.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/20-optee-identity.conf
}
