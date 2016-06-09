#!/bin/sh

base_folder=/media/psf/Home/Documents/eurecom_local/DS_local/DS_sha256
sd_path=$base_folder/utils/sd_card


cp $base_folder/build/vv/top.runs/impl_1/top_wrapper.bit $base_folder/sd_files/
cd $base_folder/sd_files
. /opt/Xilinx/.initrc > /dev/null
bootgen -w -image boot.bif -o boot.bin
. ~/.bashrc
cp boot.bin $sd_path
cd $base_folder 
