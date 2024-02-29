FILESEXTRAPATHS:prepend:aos-main-node := "${THISDIR}/files/main-node:"
FILESEXTRAPATHS:prepend:aos-secondary-node := "${THISDIR}/files/secondary-node:"

SRC_URI:append:aos-main-node = " \
    file://aos-vis-service.conf \
"

AOS_IAM_IDENT_MODULES:aos-main-node = " \
    identhandler/modules/visidentifier \
"

do_install:append:aos-main-node() {
    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -m 0644 ${WORKDIR}/aos-vis-service.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/10-aos-vis-service.conf
}
