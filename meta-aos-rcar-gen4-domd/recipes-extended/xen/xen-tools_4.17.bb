# stable-4.17 status on 5/26/2023

PV = "${XEN_REL}+stable${SRCPV}"

S = "${WORKDIR}/git"

require xen.inc
require xen-tools.inc

PACKAGECONFIG_append = " \
    xsm \
"
