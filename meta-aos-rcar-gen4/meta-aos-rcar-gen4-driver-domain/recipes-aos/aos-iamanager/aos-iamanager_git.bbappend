FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://aos-vis-service.conf \
    file://optee-identity.conf \
"

AOS_IAM_IDENT_MODULES = " \
    identhandler/modules/visidentifier \
"

AOS_IAM_CERT_MODULES = " \
    certhandler/modules/pkcs11module \
"

FILES_${PN} += " \
    ${sysconfdir} \
    ${sysconfdir}/systemd/system/aos-iamanager.service.d/ \
"

RDEPENDS_${PN} += " \
    aos-setupdisk \
    optee-pkcs11-ta \
    optee-client \
    aos-setupdisk \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -d ${D}${sysconfdir}/systemd/system/${PN}-provisioning.service.d
    install -m 0644 ${WORKDIR}/aos-vis-service.conf ${D}${sysconfdir}/systemd/system/aos-iamanager.service.d/10-aos-vis-service.conf
    install -m 0644 ${WORKDIR}/optee-identity.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/20-optee-identity.conf
    install -m 0644 ${WORKDIR}/optee-identity.conf ${D}${sysconfdir}/systemd/system/${PN}-provisioning.service.d/20-optee-identity.conf
}

