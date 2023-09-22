SRCREV = "da5282a011b40621a2cf7a296c11a35c833ed91b"

PV = "3.18.0+git${SRCPV}"

OPTEE_ARCH_aarch64 = "arm64"
TA_DEV_KIT_DIR     = "${STAGING_INCDIR}/optee/export-user_ta_${OPTEE_ARCH}"

DEPENDS_append = " python3-cryptography-native"

EXTRA_OEMAKE_append = " \
    CFLAGS64=--sysroot=${STAGING_DIR_HOST} \
"
