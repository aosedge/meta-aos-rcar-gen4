# we have to use aos-customized files
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://ufs.cfg \
"
