# Program Basys3 FPGA and download the MicroBlaze ELF.
# Run later, when the Basys3 board is connected:
#   D:\Xilinx\Vitis\2020.2\bin\xsct.bat hw/scripts/program_fpga_and_elf.tcl

set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir ".." ".."]]
set log_dir [file normalize [file join $project_root "hw" "logs"]]
file mkdir $log_dir
set timestamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
set log_path [file join $log_dir "program_fpga_and_elf_${timestamp}.log"]
set log_fd [open $log_path "w"]

proc log_msg {msg} {
    puts $msg
    puts $::log_fd $msg
    flush $::log_fd
}

proc fail {msg} {
    log_msg "ERROR: $msg"
    close $::log_fd
    exit 1
}

set bit_path [file normalize [file join $project_root "vivado" "basys3" "microblaze_axi_soc" "exports" "microblaze_axi_soc.bit"]]
set elf_path [file normalize [file join $project_root "sw" "vitis_workspace" "axi_soc_uart_app" "Debug" "axi_soc_uart_app.elf"]]

log_msg "Project root: $project_root"
log_msg "Bitstream: $bit_path"
log_msg "ELF: $elf_path"
log_msg "Log: $log_path"

if {![file exists $bit_path]} { fail "Bitstream not found: $bit_path" }
if {![file exists $elf_path]} { fail "ELF not found: $elf_path" }

if {[catch {connect} msg]} { fail "Unable to connect to hw_server: $msg" }
log_msg "Connected to hw_server."
log_msg "Available targets:"
if {[catch {targets} target_listing]} { fail "Unable to list targets: $target_listing" }
log_msg $target_listing

set fpga_filters [list \
    {name =~ "*xc7a35t*"} \
    {name =~ "*Artix*"} \
    {name =~ "*FPGA*" && name =~ "*7*"}]
set fpga_selected 0
foreach filter $fpga_filters {
    if {[catch {targets -set -filter $filter} select_msg]} {
        log_msg "FPGA filter failed: $filter -> $select_msg"
    } else {
        log_msg "Selected FPGA target with filter: $filter"
        set fpga_selected 1
        break
    }
}
if {!$fpga_selected} { fail "No Artix-7/xc7a35t FPGA target found." }

if {[catch {fpga -file $bit_path} msg]} { fail "FPGA programming failed: $msg" }
log_msg "FPGA programmed successfully."

set mb_filters [list \
    {name =~ "*MicroBlaze*"} \
    {name =~ "*microblaze*"}]
set mb_selected 0
foreach filter $mb_filters {
    if {[catch {targets -set -filter $filter} select_msg]} {
        log_msg "MicroBlaze filter failed: $filter -> $select_msg"
    } else {
        log_msg "Selected MicroBlaze target with filter: $filter"
        set mb_selected 1
        break
    }
}
if {!$mb_selected} { fail "No MicroBlaze processor target found." }

if {[catch {rst -processor} msg]} {
    log_msg "WARNING: processor reset failed or unsupported: $msg"
} else {
    log_msg "Processor reset issued."
}

if {[catch {dow $elf_path} msg]} { fail "ELF download failed: $msg" }
log_msg "ELF downloaded successfully."

if {[catch {con} msg]} { fail "Processor start failed: $msg" }
log_msg "Processor execution started."

close $log_fd
exit 0
