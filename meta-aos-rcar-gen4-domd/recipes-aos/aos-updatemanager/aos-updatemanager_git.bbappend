FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
FILESEXTRAPATHS:prepend:aos-main-node := "${THISDIR}/files/main-node:"
FILESEXTRAPATHS:prepend:aos-secondary-node := "${THISDIR}/files/secondary-node:"

RENESASOTA_IMPORT = "github.com/aosedge/aos-core-rcar-gen4"

SRC_URI += " \
    git://git@${RENESASOTA_IMPORT}.git;branch=main;protocol=ssh;name=renesasota;destsuffix=${S}/src/${GO_IMPORT}/vendor/${RENESASOTA_IMPORT} \
"

SRCREV_FORMAT = "renesasota"
SRCREV_renesasota = "81d8eb436da51f3106bc76db8823211e3d3b21fd"

FILES:${PN} += " \
    ${bindir} \
"

do_prepare_modules:append() {
    file="${S}/src/${GO_IMPORT}/updatemodules/modules.go"

    echo 'import _ "${RENESASOTA_IMPORT}/updatemodules/renesasota"' >> ${file}
}

do_compile() {
    VENDOR_PACKAGES=" \
        github.com/syucream/posix_mq \
        github.com/aosedge/aos_common/aostypes \
    "

    for package in $VENDOR_PACKAGES; do
        install -d $(dirname ${S}/src/${GO_IMPORT}/vendor/${package})
        ln -sfr ${S}/src/${GO_IMPORT}/vendor/${RENESASOTA_IMPORT}/vendor/${package} ${S}/src/${GO_IMPORT}/vendor/${package}
    done 

    cd ${S}/src/${GO_IMPORT}
    GO111MODULE=on ${GO} build -o ${B}/bin/aos_updatemanager -ldflags "-X main.GitSummary=`git --git-dir=.git describe --tags --always`"
}

do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/bin/aos_updatemanager ${D}${bindir}
}
