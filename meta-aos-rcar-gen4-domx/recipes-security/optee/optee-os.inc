FILESEXTRAPATHS:prepend := "${THISDIR}/optee-os:"

DESCRIPTION = "OP-TEE OS"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=c1f21c4f72f372ef38a5a4aee55ec173"

SRC_URI = "git://github.com/OP-TEE/optee_os.git;protocol=https;branch=master"
# optee-os 3.18.0
SRCREV = "1ee647035939e073a2e8dddb727c0f019cc035f1"

SRC_URI += " \
    file://0001-plat-rcar-fix-core-pos-calculation-for-H3-boards.patch \
    file://0001-plat-rcar-do-not-enable-console-for-Gen4.patch \
"

NO_GENERIC_LICENSE[optee-os] = "${S}/LICENSE" 

PV = "3.18.0+git${SRCPV}"

S = "${WORKDIR}/git"

inherit deploy

DEPENDS = "python3-cryptography-native"

COMPATIBLE_MACHINE ?= "(salvator-x|h3ulcb|m3ulcb|m3nulcb|spider)"
OPTEEMACHINE = "rcar"
PLATFORM = "rcar"

OPTEEFLAVOR = "${XT_OP_TEE_FLAVOUR}"

PACKAGE_ARCH = "${MACHINE_ARCH}"
export CROSS_COMPILE64="${TARGET_PREFIX}"

# Let the Makefile handle setting up the flags as it is a standalone application
LD[unexport] = "1"
LDFLAGS[unexport] = "1"
export CCcore="${CC}"
export LDcore="${LD}"
libdir[unexport] = "1"

OPTEE_ARCH:aarch64 = "arm64"

EXTRA_OEMAKE = "-e MAKEFLAGS= \
    PLATFORM=rcar \
    PLATFORM_FLAVOR=${OPTEEFLAVOR} \
    CFG_ARM64_core=y \
    CFG_VIRTUALIZATION=y \
    CROSS_COMPILE_core=${HOST_PREFIX} \
    CROSS_COMPILE_ta_${OPTEE_ARCH}=${HOST_PREFIX} \
    ta-targets=ta_${OPTEE_ARCH} \
    CFLAGS64=--sysroot=${STAGING_DIR_HOST} \
    CFG_SYSTEM_PTA=y \
    CFG_RCAR_UART=103 \
"

do_configure() {
}

FILES:${PN} = ""
FILES:${PN}-staticdev = "/usr/include/optee/"
