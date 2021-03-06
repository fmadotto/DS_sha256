#
# Copyright (C) Telecom ParisTech
# 
# This file must be used under the terms of the CeCILL. This source
# file is licensed as described in the file COPYING, which you should
# have received as part of this distribution. The terms are also
# available at:
# http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
#

proc usage {} {
	puts "usage: vivado -mode batch -source <script> -tclargs <rootdir> <builddir> \[<ila>\]"
	puts "  <rootdir>:  absolute path of DS_sha256 root directory"
	puts "  <builddir>: absolute path of build directory"
	puts "  <ila>:      embed Integrated Logic Analyzer (0 or 1, default 0)"
	exit -1
}

if { $argc == 3 } {
	set rootdir [lindex $argv 0]
	set builddir [lindex $argv 1]
	set ila [lindex $argv 2]
	if { $ila != 0 && $ila != 1 } {
		usage
	}
} else {
	usage
}

cd $builddir
set rootdir $rootdir/src
source $rootdir/scripts/ila.tcl

###################
# Create DS_SHA256 IP #
###################
create_project -part xc7z010clg400-1 -force DS_sha256 DS_sha256

# replace filenames
# add_files $rootdir/hdl/axi_pkg.vhd $rootdir/hdl/debouncer.vhd $rootdir/hdl/DS_sha256.vhd
# add_files $rootdir/hdl/axi_pkg.vhd $rootdir/hdl/ch.vhd $rootdir/hdl/cla.vhd $rootdir/hdl/compressor.vhd $rootdir/hdl/control_unit.vhd $rootdir/hdl/csa.vhd $rootdir/hdl/csigma_0.vhd $rootdir/hdl/csigma_1.vhd $rootdir/hdl/data_path.vhd $rootdir/hdl/expander.vhd $rootdir/hdl/fsm.vhd $rootdir/hdl/full_adder.vhd $rootdir/hdl/H_i_calculator.vhd $rootdir/hdl/K_j_constants.vhd $rootdir/hdl/maj.vhd $rootdir/hdl/M_j_memory.vhd $rootdir/hdl/mux_2_to_1.vhd $rootdir/hdl/reg_H_minus_1.vhd $rootdir/hdl/register.vhd $rootdir/hdl/sha256_pl.vhd $rootdir/hdl/sigma_0.vhd $rootdir/hdl/sigma_1.vhd $rootdir/hdl/start_FF.vhd 
add_files $rootdir/hdl/axi_pkg.vhd $rootdir/hdl/M_j_memory.vhd $rootdir/hdl/sha256_pl.vhd $rootdir/hdl/sha256.vhd $rootdir/hdl/start_FF.vhd 
set_property top sha256_pl [current_fileset]

import_files -force -norecurse
ipx::package_project -root_dir DS_sha256 -vendor www.telecom-paristech.fr -library DS_SHA256 -force DS_sha256
close_project

############################
## Create top level design #
############################
set top top
create_project -part xc7z010clg400-1 -force $top .
set_property board_part digilentinc.com:zybo:part0:1.0 [current_project]
set_property ip_repo_paths { ./DS_sha256 } [current_fileset]
update_ip_catalog
create_bd_design "$top"
set DS_sha256 [create_bd_cell -type ip -vlnv [get_ipdefs *www.telecom-paristech.fr:DS_SHA256:sha256_pl:*] DS_sha256]
set ps7 [create_bd_cell -type ip -vlnv [get_ipdefs *xilinx.com:ip:processing_system7:*] ps7]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" } $ps7
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50.000000}] $ps7
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1}] $ps7
set_property -dict [list CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {1}] $ps7

# Interconnections
# Primary IOs
create_bd_port -dir O done
connect_bd_net [get_bd_pins /DS_sha256/done] [get_bd_ports done]
# create_bd_port -dir O -from 3 -to 0 led
# connect_bd_net [get_bd_pins /DS_sha256/led] [get_bd_ports led]
# create_bd_port -dir I -from 3 -to 0 sw
# connect_bd_net [get_bd_pins /DS_sha256/sw] [get_bd_ports sw]
# create_bd_port -dir I btn
# connect_bd_net [get_bd_pins /DS_sha256/btn] [get_bd_ports btn]
# ps7 - DS_sha256
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps7/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins /DS_sha256/s0_axi]

# Addresses ranges
set_property offset 0x40000000 [get_bd_addr_segs -of_object [get_bd_intf_pins /ps7/M_AXI_GP0]]
set_property range 1G [get_bd_addr_segs -of_object [get_bd_intf_pins /ps7/M_AXI_GP0]]

# In-circuit debugging
if { $ila == 1 } {
	set_property HDL_ATTRIBUTE.MARK_DEBUG true [get_bd_intf_nets -of_objects [get_bd_intf_pins /DS_sha256/m_axi]]
}

# Synthesis flow
validate_bd_design
set files [get_files *$top.bd]
generate_target all $files
add_files -norecurse -force [make_wrapper -files $files -top]
save_bd_design
set run [get_runs synth*]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none $run
launch_runs $run
wait_on_run $run
open_run $run

# In-circuit debugging
if { $ila == 1 } {
	set topcell [get_cells $top*]
	set nets {}
	set suffixes {
		ARID ARADDR ARLEN ARSIZE ARBURST ARLOCK ARCACHE ARPROT ARQOS ARVALID
		RREADY
		AWID AWADDR AWLEN AWSIZE AWBURST AWLOCK AWCACHE AWPROT AWQOS AWVALID
		WID WDATA WSTRB WLAST WVALID
		BREADY
		ARREADY
		RID RDATA RRESP RLAST RVALID
		AWREADY
		WREADY
		BID BRESP BVALID
	}
	foreach suffix $suffixes {
		lappend nets $topcell/DS_sha256_m_axi_${suffix}
	}
	add_ila_core dc $topcell/ps7_FCLK_CLK0 $nets
}

# IOs
array set ios {
 	"done"		{ "M14" "LVCMOS33" }
}
# 	"sw[0]"		{ "G15" "LVCMOS33" }
# 	"sw[1]"		{ "P15" "LVCMOS33" }
# 	"sw[2]"		{ "W13" "LVCMOS33" }
# 	"sw[3]"		{ "T16" "LVCMOS33" }
# 	"led[0]"	{ "M14" "LVCMOS33" }
# 	"led[1]"	{ "M15" "LVCMOS33" }
# 	"led[2]"	{ "G14" "LVCMOS33" }
# 	"led[3]"	{ "D18" "LVCMOS33" }
# 	"btn"		{ "R18" "LVCMOS33" }
foreach io [ array names ios ] {
	set pin [ lindex $ios($io) 0 ]
	set std [ lindex $ios($io) 1 ]
	set_property package_pin $pin [get_ports $io]
	set_property iostandard $std [get_ports [list $io]]
}

# Timing constraints
set clock [get_clocks]
set_false_path -from $clock -to [get_ports {done}]
# set_false_path -from $clock -to [get_ports {led[*]}]
# set_false_path -from [get_ports {btn sw[*]}] -to $clock

# Implementation
save_constraints
set run [get_runs impl*]
reset_run $run
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true $run
launch_runs -to_step write_bitstream $run
wait_on_run $run

# Messages
set rundir ${builddir}/$top.runs/$run
puts ""
puts "\[VIVADO\]: done"
puts "  bitstream in $rundir/${top}_wrapper.bit"
puts "  resource utilization report in $rundir/${top}_wrapper_utilization_placed.rpt"
puts "  timing report in $rundir/${top}_wrapper_timing_summary_routed.rpt"
