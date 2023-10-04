do_install:append() {
    # Set domain
    echo "local=/gen4/" >> ${D}${sysconfdir}/dnsmasq.conf
    echo "domain=gen4" >> ${D}${sysconfdir}/dnsmasq.conf
    echo "expand-hosts" >> ${D}${sysconfdir}/dnsmasq.conf
}

do_install:append:aos-main-node() {
    # Serve tsn1
    echo "interface=tsn1" >> ${D}${sysconfdir}/dnsmasq.conf
    # Add gen3 DNS server
    echo "server=/gen3/10.0.0.2" >> ${D}${sysconfdir}/dnsmasq.conf
}
