FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RENESASOTA_IMPORT = "gitpct.epam.com/rec-inv/aos-core-rcar-gen4"

SRC_URI_append = " \
    git://git@${RENESASOTA_IMPORT}.git;branch=main;protocol=ssh;name=renesasota;destsuffix=${S}/src/${RENESASOTA_IMPORT} \
"

SRCREV_FORMAT = "renesasota"
SRCREV_renesasota = "${AUTOREV}"

SRC_URI_append = "\
    file://aos_updatemanager.cfg \
    file://aos-updatemanager.service \
    file://aos-reboot.service \
"

AOS_UM_UPDATE_MODULES ?= "\
    updatemodules/overlayxenstore \
    updatemodules/ubootdualpart \
"

GO_EXTLDFLAGS += "-Wl,--allow-multiple-definition"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-updatemanager.service"

MIGRATION_SCRIPTS_PATH = "${base_prefix}/usr/share/aos/um/migration"

DEPENDS_append = "\
    pkgconfig-native \
    systemd \
    efivar \
"

RDEPENDS_${PN} = " \
    aos-rootca \
"

FILES_${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
    ${MIGRATION_SCRIPTS_PATH} \
"

do_prepare_modules_append() {
    file="${S}/src/${GO_IMPORT}/updatemodules/modules.go"

    echo 'import _ "${RENESASOTA_IMPORT}/updatemodules/renesasota"' >> ${file}
}

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_updatemanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-updatemanager.service ${D}${systemd_system_unitdir}/aos-updatemanager.service
    install -m 0644 ${WORKDIR}/aos-reboot.service ${D}${systemd_system_unitdir}/aos-reboot.service

    install -d ${D}${MIGRATION_SCRIPTS_PATH}
    source_migration_path="src/${GO_IMPORT}/database/migration"
    if [ -d ${S}/${source_migration_path} ]; then
        install -m 0644 ${S}/${source_migration_path}/* ${D}${MIGRATION_SCRIPTS_PATH}
    fi
}
