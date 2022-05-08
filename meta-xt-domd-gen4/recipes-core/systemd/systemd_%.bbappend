do_install_append() {
    sed -i -e "/^After=/s/\$/ var-machine-id.service/" ${D}${systemd_system_unitdir}/systemd-journald.service
}
