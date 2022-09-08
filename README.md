# meta-xt-rcar-gen4 #

This repository contains Renesas R-Car Gen4-specific Yocto layers for
Xen Troops distro. Some layers in this repository are product-independent.
They provide common facilities that may be used by any xt-based product
that runs on Renesas Gen4-based platforms.

Those layers *may* be added and used manually, but they were written
with [Moulin](https://moulin.readthedocs.io/en/latest/) build system,
as Moulin-based project files provide correct entries in local.conf

# Status

This is a release 0.8.4 of the Xen-based development product for the
S4 Spider board.

This release provides the following features:

 - Xen build compatible with S4 SoC
 - Thin Dom0
 - Driver domain (DomD), which has access to all available hardware
 - Optional generic domain (DomU)
 - Support for OP-TEE in virtualization mode
 - ICCOM partitioning demo (proprietary components are required to
   test the feature)
 - R-Switch VMQ: R-Switch virtualization feature
 - R-Switch VMQ TSN: R-Switch TSN pass-through feature
 - Virtualized OP-TEE support
 - PCIe SR-IOV support

The following HW modules were tested and are confirmed to work:

 - Serial console (HSCIF)
 - IPMMUs
 - R-Switch
 - eMMC
 - PCIe with ITS

# External dependencies

At least IPL 0.5.0 is required for normal operation. Release was
tested with IPL 0.9.0. User is required to flash ARM TF
(bl31-spider.srec) and OP-TEE (tee-spider.srec) provided by the build
to ensure that Xen and DomD/DomU will work correctly.

# Building
## Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to [Yocto
   manual](https://www.yoctoproject.org/docs/current/mega-manual/mega-manual.html#brief-build-system-packages).
3. You need `Moulin` installed in your PC. Recommended way is to
   install it for your user only: `pip3 install --user
   git+https://github.com/xen-troops/moulin`. Make sure that your
   `PATH` environment variable includes `${HOME}/.local/bin`.
4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

## Fetching

You can fetch/clone this whole repository, but you actually only need
one file from it: `prod-aos-rcar-s4.yaml`. During the build `moulin`
will fetch this repository again into `yocto/` directory. So, to
reduce possible confuse, we recommend to download only
`prod-devel-rcar-s4.yaml`:

```
# curl -O https://raw.githubusercontent.com/xen-troops/meta-xt-prod-devel-rcar-gen4/spider-0.8.4/prod-devel-rcar-s4.yaml
```

## Building

Moulin is used to generate Ninja build file: `moulin
prod-aos-rcar-s4.yaml`. This project provides number of additional
parameters. You can check them with `--help-config` command
line option:

```
# moulin prod-aos-rcar-s4.yaml --help-config
usage: moulin prod-aos-rcar-s4.yaml [--ENABLE_DOMU {no,yes}]

Config file description: Xen-Troops development setup for Renesas RCAR Gen4
hardware

optional arguments:
  --ENABLE_DOMU {no,yes}
                        Build generic Yocto-based DomU
```

Only one machine is supported as of now: `spider`. You can enable or
disable DomU build with `--ENABLE_DOMU=yes` option.
Be default it is disabled.

So, to build with DomU (generic Yocto-based virtual machine) use the
following command line: `moulin prod-aos-rcar-s4.yaml
--ENABLE_DOMU=yes`.

Moulin will generate `build.ninja` file. After that run `ninja` to
build the images. This will take some time and disk space as it builds
3 separate Yocto images.

## Creating SD card image

### Using Ninja

Latest versions of `moulin` will generate additional ninja targets for
creating images. In case of this product please use

```
# ninja image-full
```

To generate SD/eMMC image `full.img`. You can use `dd` tool to write
this image file to a SD card:

```
# dd if=full.img of=/dev/sdX conv=sparse
```

If you want to write image directly to a SD card (e.g. without
creating `full.img` file), you will need to use manual mode, which is
described in the next subsection.

### Manually, using `rouge`

Image file can be created with `rouge` tool. This is a companion
application for `moulin`.

Right now it works only in standalone mode, so manual invocation is
required. It accepts the same parameters: `--ENABLE_DOMU`.

This XT product provides only one image: `full`.

You can prepare the image by running

```
# rouge prod-aos-rcar-s4.yaml --ENABLE_DOMU=yes -i full
```

This will create file `full.img` in your current directory.

Also you can write image directly to an SD card by running

```
# sudo rouge prod-aos-rcar.yaml --ENABLE_DOMU=yes -i full -so /dev/sdX
```

**BE SURE TO PROVIDE CORRECT DEVICE NAME**. `rouge` has no
interactive prompts and will overwrite your device right away. **ALL
DATA WILL BE LOST**.

It is also possible to flash the image to the internal eMMC.
For that you may want booting the board via TFTP and sharing DomD's
root file system via NFS. Once booted it is possible to flash the image:

```
# dd if=/full.img of=/dev/mmcblk0 bs=1M
```

For more information about `rouge` check its
[manual](https://moulin.readthedocs.io/en/latest/rouge.html).

## U-boot environment

Please make sure 'bootargs' variable is unset while running with Xen:
```
unset bootargs
```

It is possible to run the build from TFTP+NFS and eMMC. With NFS boot
is is possible to configure board IP, server IP and NFS path for DomD
and DomU. Please set the following environment for that:

```
setenv set_pcie 'i2c dev 0; i2c mw 0x6c 0x26 5; i2c mw 0x6c 0x254.2 0x1e; i2c mw 0x6c 0x258.2 0x1e; i2c mw 0x20 0x3.1 0xfe;'

setenv bootcmd 'run set_pcie; run bootcmd_tftp'
setenv bootcmd_mmc0 'run mmc0_xen_load; run mmc0_dtb_load; run mmc0_kernel_load; run mmc0_xenpolicy_load; run mmc0_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'
setenv bootcmd_tftp 'run tftp_xen_load; run tftp_dtb_load; run tftp_kernel_load; run tftp_xenpolicy_load; run tftp_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'

setenv mmc0_dtb_load 'ext2load mmc 0:1 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device mmcblk0'
setenv mmc0_initramfs_load 'ext2load mmc 0:1 0x84000000 uInitramfs'
setenv mmc0_kernel_load 'ext2load mmc 0:1 0x7a000000 Image'
setenv mmc0_xen_load 'ext2load mmc 0:1 0x48080000 xen'
setenv mmc0_xenpolicy_load 'ext2load mmc 0:1 0x7c000000 xenpolicy'

setenv tftp_configure_nfs 'fdt set /boot_dev device nfs; fdt set /boot_dev my_ip 192.168.1.2; fdt set /boot_dev nfs_server_ip 192.168.1.100; fdt set /boot_dev nfs_dir "/srv/domd"; fdt set /boot_dev domu_nfs_dir "/srv/domu"'
setenv tftp_dtb_load 'tftp 0x48000000 r8a779f0-spider-xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; run tftp_configure_nfs; '
setenv tftp_initramfs_load 'tftp 0x84000000 uInitramfs'
setenv tftp_kernel_load 'tftp 0x7a000000 Image'
setenv tftp_xen_load 'tftp 0x48080000 xen-uImage'
setenv tftp_xenpolicy_load 'tftp 0x7c000000 xenpolicy-spider'

```

## NVME configuration for SR-IOV

### One-time NVME configuration

**WARNING! The following commands will destroy all data on your NVME
drive.**

All the following commands should be ran **one time** for each SSD. They
should be performed in DomD.

To enable SR-IOV feature on Samsung SSD we need to create additional
NVME namespaces and attach one of them to a secondary controller. But
first we need to remove default namespace. Be sure to backup any data.

```
root@spider-domd:~# nvme delete-ns /dev/nvme0 -n1
```

Now we need to create at least two namespaces. In this example, they will be
totally identical in sizes (512MB) and features (no special features):

```
root@spider-domd:~# nvme create-ns /dev/nvme0 -s 1048576 -c 1048576 -d0 -m0 -f0
create-ns: Success, created nsid:1
root@spider-domd:~# nvme create-ns /dev/nvme0 -s 1048576 -c 1048576 -d0 -m0 -f0
create-ns: Success, created nsid:2
```

You can list all namespaces:

```
root@spider-domd:~# nvme list-ns /dev/nvme0 -a
[   0]:0x1
[   1]:0x2
```

At this point you might need to reboot board.

Next you'll need to attach first namespace to a primary controller
(that will reside in DomD):

```
root@spider-domd:~# nvme attach-ns /dev/nvme0 -n1 -c0x41
[   47.419062] nvme nvme0: rescanning namespaces.
attach-ns: Success, nsid:1
```

At this point you might need to reboot board again.

And attach second namespace to one of the secondary controllers:

```
root@spider-domd:~# nvme attach-ns /dev/nvme0 -n2 -c0x1
attach-ns: Success, nsid:2
```

This completes one-time setup of SSD.


### Configuring SR-IOV feature of SSD before attaching it to a DomU

Each time you want to attach virtual function to a DomU, you need to
configure SSD resources and enable SR-IOV. Execute the following commands:

```
# nvme virt-mgmt /dev/nvme0 -c 0x1 -r0 -n2 -a8
# nvme virt-mgmt /dev/nvme0 -c 0x1 -r1 -n2 -a8
# echo 1 > /sys/bus/pci/devices/0000\:01\:00.0/sriov_numvfs
# nvme virt-mgmt /dev/nvme0 -c 0x1 -a9
```

After this you can check that secondary NVME controller is online:

```
root@spider-domd:~# nvme list-secondary /dev/nvme0 -e1
Identify Secondary Controller List:
   NUMID       : Number of Identifiers           : 32
   SCEntry[0  ]:
................
     SCID      : Secondary Controller Identifier : 0x0001
     PCID      : Primary Controller Identifier   : 0x0041
     SCS       : Secondary Controller State      : 0x0001 (Online)
     VFN       : Virtual Function Number         : 0x0001
     NVQ       : Num VQ Flex Resources Assigned  : 0x0002
     NVI       : Num VI Flex Resources Assigned  : 0x0002
```

Virtual function will fail to init in DomD:

```
[  317.416769] nvme nvme1: Device not ready; aborting initialisation, CSTS=0x0
[  317.416835] nvme nvme1: Removing after probe failure status: -19
```

This is expected, because secondary controller is being enabled after kernel
tries to access the new PCI device.

`lspci` should display two NVME devices:

```
root@spider-domd:~# lspci
00:00.0 PCI bridge: Renesas Technology Corp. Device 0031
01:00.0 Non-Volatile memory controller: Samsung Electronics Co Ltd Device a824
01:00.2 Non-Volatile memory controller: Samsung Electronics Co Ltd Device a824
```

Now you can uncomment PCI configuration entries in `/etc/xen/domu.cfg`:

```
vpci="ecam"
pci=["01:00.2,seize=1"]
```

Please note that were we share second device (`01:00.2`) while first one stays in DomD.

Restart DomU. You should see a new `/dev/nvme0n1` device in DomU. This
is the second namespace attached to a secondary controller of device
that resides in DomD.


## TSN1 pass-through

In this release TSN1 network interface is assigned to DomU. DomU still
used XEN PV Network for NFS boot, because this is more
convenient. DomU expects that TSN1 ip address will be assigned using
DHCP. User can provide own IP address by editing
`/etc/systemd/network/tsn1.network` file.

vmq0 interface is disabled in this release. But it can be enabled back
by un-commenting corresponding line in `/etc/xen/domu.cfg` file in
Dom0.

# Using Aos update

## Aos U-boot environment

Aos OTA update requires special U-boot environment to be set:

```
# set load address
loadaddr=0x58000000

# update mmc0... vars to use ${aos_boot_slot
setenv mmc0_dtb_load 'ext2load mmc 0:${aos_boot_slot} 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device mmcblk0'
setenv mmc0_initramfs_load 'ext2load mmc 0:${aos_boot_slot} 0x84000000 uInitramfs'
setenv mmc0_kernel_load 'ext2load mmc 0:${aos_boot_slot} 0x7a000000 Image'
setenv mmc0_xen_load 'ext2load mmc 0:${aos_boot_slot} 0x48080000 xen'
setenv mmc0_xenpolicy_load 'ext2load mmc 0:${aos_boot_slot} 0x7c000000 xenpolicy'

# load/save aos env vars
setenv aos_default_vars 'setenv aos_boot_main 0; setenv aos_boot1_ok 1; setenv aos_boot2_ok 1; setenv aos_boot_part 0'
setenv aos_save_vars 'env export -t ${loadaddr} aos_boot_main aos_boot_part aos_boot1_ok aos_boot2_ok; fatwrite mmc 0:3 ${loadaddr} uboot.env 0x3E'
setenv aos_load_vars 'run aos_default_vars; if load mmc 0:3 ${loadaddr} uboot.env; then env import -t ${loadaddr} ${filesize}; else run aos_save_vars; fi'

# configure boots 
setenv aos_boot1 'if test ${aos_boot1_ok} -eq 1; then setenv aos_boot1_ok 0; setenv aos_boot2_ok 1; setenv aos_boot_part 0; setenv aos_boot_slot 1; echo "==== Boot from part 1"; run aos_save_vars; run bootcmd_mmc0; fi'
setenv aos_boot2 'if test ${aos_boot2_ok} -eq 1; then setenv aos_boot2_ok 0; setenv aos_boot1_ok 1; setenv aos_boot_part 1; setenv aos_boot_slot 2; echo "==== Boot from part 2"; run aos_save_vars; run bootcmd_mmc0; fi'

# Aos bootcmd
setenv bootcmd_aos 'run aos_load_vars; if test ${aos_boot_main} -eq 0; then run aos_boot1; run aos_boot2; else run aos_boot2; run aos_boot1; fi'

# Set bootcmd to Aos bootcmd. Note: ping command is WA to initialize network device.
setenv bootcmd 'ping 192.168.1.100; run bootcmd_aos'
```

**Note**: ping command before run `bootcmd_aos` is WA to properly initialize the
network device.

## Flash Aos image

In order to use Aos update functionality the image should be flashed into MMC.
It could be done using the bsp image delivered together with the Aos image:
- configure tftp U-boot variables as described above;
- put `s4-bsp` folder content into your host tftp folder;
- enter to the U-boot command line;
- the following U-boot commands will run the bsp image on the target:

```
tftp 0x48000000 s4-bsp/spider.dtb
tftp 0x48080000 s4-bsp/Image
tftp 0x84000000 s4-bsp/Initrd
setenv bootargs ""
booti 0x48080000 0x84000000 0x48000000
```

- once the bsp image is booted, up network interface:

```
ifconfig tsn0 up 192.168.1.2
```

- flash the Aos image by using ssh:

```
dd if=full.img | ssh root@192.168.1.2 "dd of=/dev/mmcblk0"
```

- reboot the board.

## Generate Aos update image

Aos update image generation is done by dom0 yocto. The Aos image requires
moulin build is successfully done. It means, after doing any source changes,
`ninja` build command should be issued before generating the Aos image.

The following commands should be performed to generate the Aos image:

```
cd yocto/
source poky/oe-init-build-env build-dom0/
bitbake aos-update
```

It will generate Aos update image according to the Aos update variables set in
`prod-aos-rcar-s4.yaml` file. The default image location is your top build
folder.

Aos update variables:
- `BUNDLE_IMAGE_VERSION` - specifies image version of all components included to
the Aos update image. Individual component version can be assigned using
`DOM0_IMAGE_VERSION` for Dom0, `DOMD_IMAGE_VERSION` for DomD;
- `BUNDLE_OSTREE_REPO` - specifies path to ostree repo. ostree repo is required to generate incremental update.
It is set to `${TOPDIR}/../../rootfs_repo` by default;
- `BUNDLE_REF_VERSION` - used as default reference version for generating
incremental component update. Individual component reference version can be
specified using corresponding component variable: `DOMD_REF_VERSION` for DomD;
- `BUNDLE_DOM0_TYPE`, `BUNDLE_DOMD_TYPE`, `BUNDLE_RH850_TYPE` - specifies component update type:
   * `full` - full component update;
   * `incremental` - incremental component update (currently supported only by
DomD);
   * if not set - the component update will not be included into the Aos update
image;
   * RH850 update image is not included into the update bundle by default.
- `RH850_IMAGE_VERSION` - version of RH850 component update;
- `RH850_IMAGE_PATH` - path to the RH850 update image which should be included into the update bundle.

### Generating Aos update image example

- perform required changes in the source;
- change the `BUNDLE_IMAGE_VERSION`;
- set components build type if required (`BUNDLE_DOM0_TYPE`, `BUNDLE_DOMD_TYPE`);
- set `BUNDLE_RH850_TYPE: "full"`, `RH850_IMAGE_VERSION`, `RH850_IMAGE_PATH` if RH850 image should be included into
the update bundle;
- perform moulin build by issuing `ninja` build command;
- generate Aos image update as described above.
