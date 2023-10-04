hostname:aos-main-node = ""

do_install:append:aos-main-node() {
   echo ${AOS_NODE_HOSTNAME} > ${D}${sysconfdir}/hostname
}
