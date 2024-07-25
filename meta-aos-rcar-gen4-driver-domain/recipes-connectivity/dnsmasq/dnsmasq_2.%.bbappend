do_install:append() {
    echo "bind-dynamic" >> ${D}${sysconfdir}/dnsmasq.conf
}

do_install:append:aos-main-node() {
    # Serve tsn1
    echo "interface=tsn1" >> ${D}${sysconfdir}/dnsmasq.conf
}
