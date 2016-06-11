# DS_sha256
#### sha256 HW accelerator - DS project - Spring 2016
###### Copyright (c) 2016 Federico Madotto and Coline Doebelin

This repository and its sub-directories contain the VHDL source code, VHDL simulation environment, simulation, synthesis scripts and software for DS_sha256, a simple design example for the Xilinx Zynq core. It was specifically designed for the Zybo board by Digilent.
All provided instructions are for a host computer running a GNU/Linux operating system and have been tested on a Ubuntu 14.04.4 LTS distribution. Porting to other GNU/Linux distributions should be very easy. If you are working under Microsoft Windows or Apple Mac OS X, installing a virtualisation framework and running an Ubuntu OS on a virtual machine is probably the easiest path.

This work is based on the very interesting [SAB4Z project](https://gitlab.eurecom.fr/renaud.pacalet/sab4z) by Renaud Pacalet, who kindly helped us to successfully complete this design.
If you have any problem when running this project, first check on the [SAB4Z project page](https://gitlab.eurecom.fr/renaud.pacalet/sab4z) for a solution: it is likely that you will find useful information there.

Please signal errors and send suggestions for improvements to federico.madotto (at) gmail.com.

    .
    ├── LICENSE                                    License (English version)
    ├── sd_files                
    │   ├── boot.bif         
    │   ├── boot.bin
    |   ├── devicetree.dtb
    |   ├── fsbl.elf
    |   ├── put_these_files_on_the_sd.tar.gz
    |   ├── top_wrapper.bit
    |   ├── u-boot.elf
    |   ├── ulmage
    │   └── uramdisk.image.gz
    ├── src                     
    │   ├── hdl                                    VHDL source code
    │   │   ├── axi_pkg.vhd                        Package of AXI definitions
    │   │   ├── M_j_memory.vhd
    │   │   ├── sha256.vhd
    │   │   ├── sha256_pl.vhd
    │   │   ├── sha256_tb.vhd
    │   │   ├── start_FF.vhd
    │   │   └── old_design
    │   │       ├── H_i_calculator.vhd
    │   │       ├── K_j_constants.vhd
    │   │       ├── M_j_memory_single_port.vhd
    │   │       ├── M_j_memory_single_port_tb.vhd
    │   │       ├── ch.vhd
    │   │       ├── cla.vhd
    │   │       ├── cla_tb.vhd
    │   │       ├── compressor.vhd
    │   │       ├── control_unit.vhd
    │   │       ├── csa.vhd
    │   │       ├── csigma_0.vhd
    │   │       ├── csigma_1.vhd
    │   │       ├── data_path.vhd
    │   │       ├── expander.vhd
    │   │       ├── expander_tb.vhd
    │   │       ├── fsm.vhd
    │   │       ├── fsm_tb.vhd
    │   │       ├── full_adder.vhd
    │   │       ├── maj.vhd
    │   │       ├── mux_2_to_1.vhd
    │   │       ├── reg_H_minus_1.vhd
    │   │       ├── register.vhd
    │   │       ├── sha256_pl_old.vhd
    │   │       ├── sigma_0.vhd
    │   │       └── sigma_1.vhd
    │   ├── scripts                                Scripts
    │   │   ├── boot.bif                           Zynq Boot Image description File
    │   │   ├── dts.tcl                            TCL script for device tree generation
    │   │   ├── fsbl.tcl                           TCL script for FSBL generation
    │   │   ├── ila.tcl                            TCL script for ILA debug cores
    │   │   ├── uEnv.txt                           Definitions of U-Boot environment variables
    │   │   └── vvsyn.tcl                          Vivado TCL synthesis script
    │   └── sh                 
    │       └── sha256.sh
    ├── Makefile                                   Main makefile
    ├── README.md                                  This file
    └── utils                   
        ├── copy_new_pl_to_sd.sh
        ├── extra_warnings.sh
        └── sha_test.py



---


| Address       | Mapping         | Description                                 | 
| :------------ | :---------------| :------------------------------------------ | 
| `0x4000_0000` | Status register | 32 bits read-only status register           | 
| `0x4000_0004` | M<sub>0</sub>              | 32 bits write-only register                 | 
| `0x4000_0008` | M<sub>1</sub>              | 32 bits write-only register                 | 
| ...           | ...             | ...                                         | 
| `0x4000_0040` | M<sub>15</sub>             | 32 bits write-only register                 | 
| `0x4000_0044` | start           | 32 bits write-only register                 | 
| `0x4000_0048` | H<sub>A</sub><sup>(i-1)</sup>       | 32 bits read-only register                  | 
| `0x4000_004c` | H<sub>B</sub><sup>(i-1)</sup>       | 32 bits read-only register                  | 
| ...           | ...             | ...                                         | 
| `0x4000_0064` | H<sub>H</sub><sup>(i-1)</sup>        | 32 bits read-only register                  | 



## <a name="setup"></a>Quick setup: how to run the project

#### <a name="notation"></a>Notation

Since different prompts for different contexts are used, this will be the notation used in this README:

* `$ ` is the shell prompt of a regular user on the host PC.
* `XILINX $ ` is the prompt of a regular user on the host PC *with the Xilinx software environment variables set*.
* `# ` is the shell prompt of the *root* user on the host PC..
* `Sab4z> ` is the shell prompt of the root user on the Zybo board.

#### <a name="copyfilesd"></a>Copy the files to the MicroSD card

Download the archive, insert a MicroSD card in your card reader and unpack the archive to it:

    $ cd /tmp
    $ wget https://github.com/fmadotto/DS_sha256/blob/master/sd_files/put_these_files_on_the_sd.tar.gz
    $ tar -C <path-to-mounted-sd-card> -xf put_these_files_on_the_sd.tar.gz
    $ sync
    $ umount <path-to-mounted-sd-card>

Eject the MicroSD card.

#### <a name="runonzybo"></a>Run DS_sha256 on the Zybo

* Plug the MicroSD card in the Zybo and connect the USB cable.
* Check the position of the jumper that selects the power source (USB or power adapter).
* Check the position of the jumper that selects the boot medium (MicroSD card).
* Power on. Two new character devices should show up (`/dev/ttyUSB0` and `/dev/ttyUSB1` by default) on the host PC. `/dev/ttyUSB1` is the one corresponding to the serial link with the Zybo.
* Launch a terminal emulator (picocom, minicom...) and attach it to the new character device, with a 115200 baudrate, no flow control, no parity, 8 bits characters, no port reset and no port locking (`picocom -b115200 -fn -pn -d8 -r -l /dev/ttyUSB1`).
* Wait until Linux boots, log in as root (no password needed) and start interacting with DS_sha256.

    Host> picocom -b115200 -fn -pn -d8 -r -l /dev/ttyUSB1
    ...
    Welcome to SAB4Z (c) Telecom ParisTech
    sab4z login: root
    Sab4z>
    
    
.............


To launch:

- Extract the ./sd_files/put_these_files_on_the_sd.tar.gz archive and put the files on the SD card of the Zybo

- Connect the Zybo to your computer and launch a terminal to speak with the board

picocom -b115200 -fn -pn -d8 -r -l /dev/ttyUSB1

- login as root (no pw)

- mount the SD card:
mount /dev/mmcblk0p1 /mnt

- check that the files are really there:
ls -al /mnt


- launch /mnt/sha256.sh with the required string and wait for the result
/mnt/sha256.sh foobaraaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa


- unmount the SD card and poweroff
umount /mnt
poweroff
