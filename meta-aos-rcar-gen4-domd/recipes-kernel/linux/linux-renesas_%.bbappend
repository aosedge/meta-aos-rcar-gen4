FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://aos.cfg \
    file://ixgbe.cfg \
    file://ufs.cfg \
    file://xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://0001-clk-shmobile-Hide-clock-for-scif3-and-hscif0.patch \
    file://0001-xen-blkback-update-persistent-grants-enablement-logi.patch \
    file://0001-clk-sdhi-Disable-sdhi-clocks.patch \
"

# This patch is required for the correct build of domd.dts,
# as it provides gic_its node.
SRC_URI_append = " \
    file://0002-PCIe-MSI-support.patch \
"

# HACK
# File disable_pcie.cfg desables few PCI related options.
# This is required only for xen's branch spider-aos-demo-2023
# and need to be removed as soon as PCI works as expected.
SRC_URI_append = " \
    file://disable_pcie.cfg \
"

KERNEL_MODULE_PROBECONF += "ixgbevf"
module_conf_ixgbevf = "blacklist ixgbevf"

do_configure_append() {
    if ${@bb.utils.contains('DOM0_OS', 'zephyr', 'true', 'false', d)}; then
        sed -i -e 's/dom0_mem=.[^\s]* /dom0_mem=256M /' ${S}/arch/arm64/boot/dts/renesas/xen-chosen.dtsi
    else
        sed -i -e 's/dom0_mem=.[^\s]* /dom0_mem=1024M /' ${S}/arch/arm64/boot/dts/renesas/xen-chosen.dtsi
    fi
}
