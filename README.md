# DS_sha256
### sha256 HW accelerator - DS project - Spring 2016
Copyright (c) 2016 Federico Madotto and Coline Doebelin

This repository and its sub-directories contain the VHDL source code, VHDL simulation environment, simulation, synthesis scripts and software for DS_sha256, a simple design example for the Xilinx Zynq core. It was specifically designed for the Zybo board by Digilent.
All provided instructions are for a host computer running a GNU/Linux operating system and have been tested on a Ubuntu 14.04.4 LTS distribution. Porting to other GNU/Linux distributions should be very easy. If you are working under Microsoft Windows or Apple Mac OS X, installing a virtualisation framework and running an Ubuntu OS on a virtual machine is probably the easiest path.

Please signal errors and send suggestions for improvements to federico.madotto (at) gmail.com.

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
