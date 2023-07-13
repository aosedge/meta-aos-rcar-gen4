require recipes-core/images/aos-image.inc

# System components
IMAGE_INSTALL += " \
    openssh \
    iperf3 \
    snort \
"
