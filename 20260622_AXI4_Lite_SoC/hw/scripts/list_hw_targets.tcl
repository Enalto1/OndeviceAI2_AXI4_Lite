# List available hardware targets only. Does not program the FPGA.
# Run later, when the Basys3 board is connected:
#   D:\Xilinx\Vitis\2020.2\bin\xsct.bat hw/scripts/list_hw_targets.tcl

set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir ".." ".."]]
set log_dir [file normalize [file join $project_root "hw" "logs"]]
file mkdir $log_dir
set timestamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
set log_path [file join $log_dir "list_hw_targets_${timestamp}.log"]
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

log_msg "Project root: $project_root"
log_msg "Log: $log_path"

if {[catch {connect} msg]} { fail "Unable to connect to hw_server: $msg" }
log_msg "Connected to hw_server."
log_msg "Available targets:"
if {[catch {targets} target_listing]} { fail "Unable to list targets: $target_listing" }
log_msg $target_listing

close $log_fd
exit 0
