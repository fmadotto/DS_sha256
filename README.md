# DS_sha256
sha256 HW accelerator - DS project - Spring 2016

Federico Madotto
Coline Doebelin


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