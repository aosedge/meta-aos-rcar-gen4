do_install:append:aos-main-node() {
    # Serve tsn1
    echo "interface=tsn1" >> ${D}${sysconfdir}/dnsmasq.conf
}
