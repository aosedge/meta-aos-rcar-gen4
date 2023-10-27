# meta-aos-rcar-gen4

This repository contains Renesas R-Car Gen4-specific Yocto layers for AosEdge distro.

## Status

This is a release 2.0.0 of AosEdge development product for the S4 Spider board. This release provides the following
features:

* Dom0 with Zephyr OS to run unikernels as xen domains using xrun
* DomD with Linux OS to run container based Aos services using crun
* Generating FOTA bundles
* Generating Aos layers

## Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to
[Yocto manual](https://www.yoctoproject.org/docs/current/mega-manual/mega-manual.html#brief-build-system-packages)
3. You need `Moulin` installed in your PC. Recommended way is to install it for your user only:

    ```sh
    pip3 install --user git+https://github.com/xen-troops/moulin`
    ```

    Make sure that your `PATH` environment variable includes `${HOME}/.local/bin`
4. Ninja build system on Ubuntu:

    ```sh
    sudo apt install ninja-build
    ```
  
5. Install Zephyr OS dependencies and SDK:
[Getting Started Guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html#)

## Create image

### Fetch

You can fetch/clone this whole repository, but you actually only need one file from it: `aos-rcar-gen4.yaml`. During the
build `moulin` will fetch this repository again into `yocto/` directory. So, to reduce possible confuse, we recommend to
download only `aos-rcar-gen4.yaml`:

```sh
curl -O https://raw.githubusercontent.com/aoscloud/meta-aos-rcar-gen4/main/aos-rcar-gen4.yaml
```

### Build

Moulin is used to generate Ninja build file: `moulin aos-rcar-gen4.yaml`. This project provides number of additional
parameters. You can check them with `--help-config` command line option:

```sh
moulin aos-rcar-gen4.yaml --help-config        
usage: moulin aos-rcar-gen4.yaml [--VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}]
                                 [--NODE_TYPE {single,main}]

Config file description: Aos development setup for Renesas RCAR Gen4 hardware

options:
  --VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}
                        Specifies plugin for VIS automotive data
  --NODE_TYPE {single,main}
                        Node type to build

```

Only one machine is supported as of now: `spider`.
Two types of nodes can be built: `single` - where S4 board is single unit or `main` where S4 board is main node in
multi-node unit.

For example, to build the main node image for multi-node Aos unit, perform the following command:

```sh
moulin aos-rcar-gen4.yaml --NODE_TYPE main
```

Moulin will generate `build.ninja` file that contains different build targets. Run `ninja` command to build image
components. This will take some time and disk space.

### Init UFS

Aos image should be flashed to UFS on S4 board. Other storages are not supported. UFS storage should be properly
initialized before usage. See `R-Car S4 Startup Guide` for details. Use `misc/config_desc_data_ind_0.bin`.

### Update firmware

Aos image requires specific firmware version to work properly. Updating the firmware should be done for each new Aos
release. Perform the following command in order to build firmware images:

```sh
ninja pack-ipl
```

It will generate firmware archive under `output/ipl` folder. Please use
[RCar flash tool](https://github.com/xen-troops/rcar_flash) to update the firmware.

### Flash image

To generate Aos image, issue the following command:

```sh
ninja full.img
```

It will generate `full.img` file in the current folder. In order to flash Aos image to S4 UFS, the board should be boot
using BSP image over TFTP+NFS. See `R-Car S4 Startup Guide` for details. Once, the board is started, put `full.img`
into NFS folder and copy the image into UFS, using the following command on S4 board:

```sh
dd if=/full.img of=/dev/sda bs=32M
```

Alternatively, [prod-devel-rcar-gen4](https://github.com/xen-troops/meta-xt-prod-devel-rcar-gen4) build could be used
to start the board over TFTP+NFS.

### U-Boot environment

The following U-Boot variable should be set for Aos image:

```sh
setenv aos_device 'scsi 0'
setenv aos_boot_device 'sda'
setenv aos_default_vars 'setenv aos_boot_main 0; setenv aos_boot1_ok 1; setenv aos_boot2_ok 1; setenv aos_boot_part 0'
setenv aos_load_vars 'run aos_default_vars; if load ${aos_device}:3 ${loadaddr} uboot.env; then env import -t ${loadaddr} ${filesize}; fi'
setenv aos_save_vars 'env export -t ${loadaddr} aos_boot_main aos_boot_part aos_boot1_ok aos_boot2_ok; fatwrite ${aos_device}:3 ${loadaddr} uboot.env 0x3E'
setenv aos_boot1 'if test ${aos_boot1_ok} -eq 1; then setenv aos_boot1_ok 0; setenv aos_boot2_ok 1; setenv aos_boot_part 0; setenv aos_boot_slot 1; echo "==== Boot from part 1"; run aos_save_vars; run aos_boot_cmd; fi'
setenv aos_boot2 'if test ${aos_boot2_ok} -eq 1; then setenv aos_boot2_ok 0; setenv aos_boot1_ok 1; setenv aos_boot_part 1; setenv aos_boot_slot 2; echo "==== Boot from part 2"; run aos_save_vars; run aos_boot_cmd; fi'
setenv aos_boot_cmd 'ext2load ${aos_device}:${aos_boot_slot} 0x83000000 boot.uImage; source 0x83000000'
setenv bootcmd_aos 'run aos_load_vars; if test ${aos_boot_main} -eq 0; then run aos_boot1; run aos_boot2; else run aos_boot2; run aos_boot1; fi'
setenv set_pcie 'i2c dev 0; i2c mw 0x6c 0x26 5; i2c mw 0x6c 0x254.2 0x1e; i2c mw 0x6c 0x258.2 0x1e; i2c mw 0x20 0x3.1 0xfe;'
setenv set_ufs 'i2c dev 0; i2c mw 0x6c 0x26 0x05; i2c olen 0x6c 2; i2c mw 0x6c 0x13a 0x86; i2c mw 0x6c 0x268 0x06; i2c mw 0x6c 0x269 0x00; i2c mw 0x6c 0x26a 0x3c; i2c mw 0x6c 0x26b 0x00; i2c mw 0x6c 0x26c 0x06; i2c mw 0x6c 0x26d 0x00; i2c mw 0x6c 0x26e 0x3f; i2c mw 0x6c 0x26f 0x00'
setenv bootcmd 'run set_pcie; run set_ufs; scsi scan; run bootcmd_aos'
```

## Misc

In case multi-node Aos unit, S4 provide ethernet connection for other node. In some cases, it is required to have direct
connection between the host and the secondary node. For this purpose, `tsn0` and `tsn1` S4 interfaces can be put into
the bridge. Use the following commands on S4 board to make bridge between the host and the secondary node:

```sh
brctl addbr br0
brctl addif br0 tsn0
brctl addif br0 tsn1
ifconfig br0 up
```

## FOTA & Layers

* [Generate FOTA bundles](https://github.com/aoscloud/meta-aos-vm/blob/main/doc/fota.md)
* [Generate layers](https://github.com/aoscloud/meta-aos-vm/blob/main/doc/layers.md)
