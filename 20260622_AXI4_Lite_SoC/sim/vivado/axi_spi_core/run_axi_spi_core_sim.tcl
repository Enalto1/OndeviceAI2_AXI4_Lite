# Vivado 2020.2 batch simulation script for axi_spi_core.
# Run from the canonical project root:
#   D:/Xilinx/Vivado/2020.2/bin/vivado.bat -mode batch -source sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl

set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir .. .. ..]]
cd $project_root

set sim_dir [file join $project_root sim vivado axi_spi_core]
set result_file [file join $sim_dir axi_spi_core_sim_result.txt]
set log_dir [file join $sim_dir logs]
file mkdir $log_dir
set stamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
set vivado_log_copy [file join $log_dir "axi_spi_core_sim_${stamp}_vivado.log"]
set xsim_log_copy [file join $log_dir "axi_spi_core_sim_${stamp}_xsim.log"]

if {[file exists $result_file]} {
    file delete -force $result_file
}

set work_dir [file join $sim_dir vivado_work]
create_project axi_spi_core_sim $work_dir -part xc7a35tcpg236-1 -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

set spi_master_file [file join $project_root axi_project_unique_sources sources spi_master_byte.sv]
set wrapper_file [file join $project_root rtl_work axi_peripherals axi_spi_core hdl axi_spi_core.v]
set tb_file [file join $project_root sim vivado axi_spi_core tb_axi_spi_core.sv]

add_files -norecurse [list \
    $spi_master_file \
    $wrapper_file \
]
set_property file_type SystemVerilog [get_files $spi_master_file]

add_files -fileset sim_1 -norecurse $tb_file
set_property file_type SystemVerilog [get_files $tb_file]
set_property top tb_axi_spi_core [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -dict [list xsim.simulate.xsim.more_options [list -testplusarg "RESULT_FILE=$result_file"]] [get_filesets sim_1]

set sim_status [catch {launch_simulation -simset sim_1 -mode behavioral} sim_msg]

if {[current_sim] ne ""} {
    close_sim
}

set xsim_log_src [file join $work_dir axi_spi_core_sim.sim sim_1 behav xsim simulate.log]
if {[file exists [file join $project_root vivado.log]]} {
    file copy -force [file join $project_root vivado.log] $vivado_log_copy
}
if {[file exists $xsim_log_src]} {
    file copy -force $xsim_log_src $xsim_log_copy
}
puts "Vivado log copy: $vivado_log_copy"
puts "XSim log copy: $xsim_log_copy"

if {$sim_status != 0} {
    puts "ERROR: launch_simulation failed: $sim_msg"
    exit 1
}

if {![file exists $result_file]} {
    puts "ERROR: Simulation result file was not created: $result_file"
    exit 1
}

set fp [open $result_file r]
set result_text [read $fp]
close $fp
puts "Simulation result: $result_text"

if {[string first "PASS" $result_text] >= 0} {
    exit 0
}

exit 1