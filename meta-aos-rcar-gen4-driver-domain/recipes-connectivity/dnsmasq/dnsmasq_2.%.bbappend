do_install:append:aos-main-node() {
    # Serve tsn1
    echo "bind-dynamic" >> ${D}${sysconfdir}/dnsmasq.conf
    echo "interface=tsn1" >> ${D}${sysconfdir}/dnsmasq.conf
}
