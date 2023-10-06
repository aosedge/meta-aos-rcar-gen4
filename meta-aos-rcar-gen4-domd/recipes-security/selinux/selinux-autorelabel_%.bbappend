do_install:append() {
    # TODO: Removing .nvme-work dir is a temporay solution. It's necessary for proper volitile binds mounting.
    sed -i '/\/sbin\/reboot/i \
    rm -rf /var/.nvme-work\n\
    sync\n\
    xenstore-write control/user-reboot 2' ${D}${bindir}/${SELINUX_SCRIPT_SRC}.sh
}
