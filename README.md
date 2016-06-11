# DS_sha256
#### sha256 HW accelerator - DS project - Spring 2016
###### Copyright (c) 2016 Federico Madotto and Coline Doebelin

This repository and its sub-directories contain the VHDL source code, VHDL simulation environment, simulation, synthesis scripts and software for DS_sha256, a simple design example for the Xilinx Zynq core. It was specifically designed for the Zybo board by Digilent.
All provided instructions are for a host computer running a GNU/Linux operating system and have been tested on a Ubuntu 14.04.4 LTS distribution. Porting to other GNU/Linux distributions should be very easy. If you are working under Microsoft Windows or Apple Mac OS X, installing a virtualisation framework and running an Ubuntu OS on a virtual machine is probably the easiest path.

This work is based on the very interesting [SAB4Z project](https://gitlab.eurecom.fr/renaud.pacalet/sab4z) by Renaud Pacalet, who kindly helped us to successfully complete this design.
If you have any problem when running this project, first check on the [SAB4Z project page](https://gitlab.eurecom.fr/renaud.pacalet/sab4z) for a solution: it is likely that you will find useful information there.

Please signal errors and send suggestions for improvements to federico.madotto (at) gmail.com.


## Table of content
* [License](#License)
* [Content](#Content)
* [Description](#Description)
* [Quick setup: how to run the project](#setup)
    * [Notation](#notation)
    * [Copy the files to the MicroSD card](#copyfilesd)
    * [Run DS_sha256 on the Zybo](#runonzybo)
    * [Halt the system](#RunHalt)

## <a name="License"></a>License
Copyright (c) 2016 Federico Madotto and Coline Doebelin
Based on the [SAB4Z project](https://gitlab.eurecom.fr/renaud.pacalet/sab4z) by Renaud Pacalet at Telecom ParisTech.

DS_sha256 is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

DS_sha256 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

# <a name="Content"></a>Content

    .
    ├── LICENSE                                    License (English version)
    ├── sd_files                
    │   ├── boot.bif         
    │   ├── boot.bin
    |   ├── devicetree.dtb
    |   ├── fsbl.elf
    |   ├── put_these_files_on_the_sd.tar.gz       Archive to extract on the SD card
    |   ├── top_wrapper.bit
    |   ├── u-boot.elf
    |   ├── ulmage
    │   └── uramdisk.image.gz
    ├── src                     
    │   ├── hdl                                    VHDL source code
    │   │   ├── axi_pkg.vhd                        Package of AXI definitions
    │   │   ├── M_j_memory.vhd                     Memory to store the values of the 512-bit message to hash
    │   │   ├── sha256.vhd                         Implementation of the sha256 hash function
    │   │   ├── sha256_pl.vhd                      Top-level entity
    │   │   ├── sha256_tb.vhd                      Test bench for testing sha256.vhd
    │   │   ├── start_FF.vhd                       Auto-resetting flip flop for the start signal
    │   │   └── old_design                         VHDL sources of the old design. Use freely!
    │   │       └── ...
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
    ├── images                                     Figures
    |   └── sha256_diagram.png                         Zybo board
    └── utils                   
        ├── extract_warnings.sh                    Extracts the warnings found in ./build/vv/vivado.log
        └── sha_test.py                            Python implementation of the sha256 function. For debugging.



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


![sha256 on a Zybo board](images/sha256_diagram.png)


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

- Extract the `./sd_files/put_these_files_on_the_sd.tar.gz` archive and put the files on the SD card of the Zybo

- Connect the Zybo to your computer and launch a terminal to speak with the board

        picocom -b115200 -fn -pn -d8 -r -l /dev/ttyUSB1

- login as root (no pw)

- mount the SD card:

        mount /dev/mmcblk0p1 /mnt

- check that the files are really there:

        ls -al /mnt


- launch `/mnt/sha256.sh` with the required string and wait for the result

        /mnt/sha256.sh foobaraaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa


- unmount the SD card and poweroff

        umount /mnt
        poweroff

#### <a name="RunHalt"></a>Halt the system

Always halt properly before switching the power off:

    Sab4z> poweroff
    Sab4z> Stopping network...Saving random seed... done.
    Stopping logging: OK
    umount: devtmpfs busy - remounted read-only
    umount: can't unmount /: Invalid argument
    The system is going down NOW!
    Sent SIGTERM to all processes
    Sent SIGKILL to all processes
    Requesting system poweroff
    reboot: System halted
