do_install:append() {
    # TODO: This is a temporary solution. It's necessary for proper volitile binds mounting. 
    sed -i '/\/sbin\/reboot/i \    rm -rf /var/.nvme-work' ${D}${bindir}/${SELINUX_SCRIPT_SRC}.sh
}
