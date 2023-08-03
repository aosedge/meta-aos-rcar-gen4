require recipes-core/images/aos-image.inc

# System components
IMAGE_INSTALL:append = " \
    openssh \
    iperf3 \
    snort \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-tools-pcid \
    xen-network \
    dnsmasq \
"
