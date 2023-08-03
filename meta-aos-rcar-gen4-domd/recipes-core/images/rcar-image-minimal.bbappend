require recipes-core/images/aos-image.inc

# System components
IMAGE_INSTALL:append = " \
    openssh \
    iperf3 \
    snort \
"
