# Build the Basys3 MicroBlaze AXI4-Lite SoC through bitstream and XSA export.
# Vivado 2020.2 batch command from project root:
# D:/Xilinx/Vivado/2020.2/bin/vivado.bat -mode batch -source vivado/scripts/build_microblaze_basys3_bitstream.tcl

proc write_lines {path lines} {
    set fh [open $path w]
    foreach line $lines {
        puts $fh $line
    }
    close $fh
}

set summary_lines [list]
set summary_path ""

proc add_summary {line} {
    global summary_lines
    lappend summary_lines $line
    puts $line
}

proc write_build_summary {} {
    global summary_path summary_lines
    if {$summary_path ne ""} {
        write_lines $summary_path $summary_lines
    }
}

proc fail {msg} {
    add_summary "RESULT: FAIL"
    add_summary "FAILURE: $msg"
    write_build_summary
    catch {close_design}
    catch {close_project}
    puts stderr "ERROR: $msg"
    exit 1
}

proc require_file {path label} {
    if {![file exists $path]} {
        fail "$label not found: $path"
    }
}

proc require_one {objects label} {
    if {[llength $objects] != 1} {
        fail "Expected exactly one $label, found [llength $objects]: $objects"
    }
    return [lindex $objects 0]
}

proc check_run_complete {run_name stage_label} {
    set run_obj [require_one [get_runs $run_name -quiet] "run $run_name"]
    set status [get_property STATUS $run_obj]
    set progress [get_property PROGRESS $run_obj]
    add_summary "$stage_label run status: $status"
    add_summary "$stage_label run progress: $progress"
    if {[regexp -nocase {fail|error|cancel} $status]} {
        fail "$stage_label run failed: $status"
    }
    if {![regexp -nocase {complete} $status] && $progress ne "100%"} {
        fail "$stage_label run did not complete: status=$status progress=$progress"
    }
}

proc get_path_slack_or_na {delay_type} {
    set paths [get_timing_paths -delay_type $delay_type -max_paths 1 -quiet]
    if {[llength $paths] == 0} {
        return "N/A"
    }
    return [get_property SLACK [lindex $paths 0]]
}

proc numeric_nonnegative_or_na {value} {
    if {$value eq "N/A" || $value eq ""} {
        return 1
    }
    if {[catch {expr {$value >= 0.0}} ok]} {
        return 0
    }
    return $ok
}

proc collect_drc_counts {} {
    array set counts {ERROR 0 CRITICAL_WARNING 0 WARNING 0 INFO 0 OTHER 0 TOTAL 0}
    set violations [get_drc_violations -quiet]
    foreach violation $violations {
        incr counts(TOTAL)
        set sev [string toupper [get_property SEVERITY $violation]]
        set sev_key [string map {" " "_"} $sev]
        if {[info exists counts($sev_key)]} {
            incr counts($sev_key)
        } else {
            incr counts(OTHER)
        }
    }
    return [array get counts]
}

proc copy_first_bitstream {impl_dir export_bit} {
    set candidates [glob -nocomplain [file join $impl_dir *.bit]]
    if {[llength $candidates] == 0} {
        fail "No bitstream found in implementation directory: $impl_dir"
    }
    set source_bit [lindex [lsort $candidates] 0]
    file copy -force $source_bit $export_bit
    return $source_bit
}

set script_path [file normalize [info script]]
set script_dir [file dirname $script_path]
set root_dir [file normalize [file join $script_dir .. ..]]
set vivado_exe "D:/Xilinx/Vivado/2020.2/bin/vivado.bat"
set project_dir [file join $root_dir vivado basys3 microblaze_axi_soc]
set project_path [file join $project_dir microblaze_axi_soc.xpr]
set bd_name microblaze_axi_soc_bd
set bd_path [file join $project_dir microblaze_axi_soc.srcs sources_1 bd $bd_name ${bd_name}.bd]
set wrapper_path [file join $project_dir microblaze_axi_soc.gen sources_1 bd $bd_name hdl ${bd_name}_wrapper.v]
set xdc_path [file join $root_dir constraints basys3 basys3_axi_soc.xdc]
set report_dir [file join $project_dir reports]
set export_dir [file join $project_dir exports]
set impl_dir [file join $project_dir microblaze_axi_soc.runs impl_1]
set export_bit [file join $export_dir microblaze_axi_soc.bit]
set export_xsa [file join $export_dir microblaze_axi_soc.xsa]
set summary_path [file join $report_dir bitstream_build_summary.txt]
set jobs 4

file mkdir $report_dir
file mkdir $export_dir

add_summary "Vivado executable expected: $vivado_exe"
add_summary "Vivado version: [version -short]"
add_summary "Project root: $root_dir"
add_summary "Project: $project_path"
add_summary "Block design: $bd_path"
add_summary "Wrapper: $wrapper_path"
add_summary "XDC: $xdc_path"
add_summary "Report directory: $report_dir"
add_summary "Export directory: $export_dir"

if {[string first "2020.2" [version -short]] < 0} {
    fail "Expected Vivado 2020.2, got [version -short]"
}

require_file $project_path "Vivado project"
require_file $bd_path "Block design"
require_file $wrapper_path "HDL wrapper"
require_file $xdc_path "Basys3 XDC"

if {[catch {
    open_project $project_path
    open_bd_design $bd_path

    foreach cell_name {microblaze_0 mdm_0 proc_sys_reset_0 smartconnect_0 axi_uartlite_0 axi_gpio_core_0 axi_fnd_core_0 axi_timer_core_0 axi_sensor_core_0 axi_spi_core_0 axi_i2c_core_0 rstn_inv_0} {
        require_one [get_bd_cells $cell_name -quiet] "BD cell $cell_name"
    }
    foreach port_name {clk_100mhz_i reset_i uart_rxd_i uart_txd_o led_o sw_i btn_i fnd_com_o fnd_data_o sr04_echo_i sr04_trig_o dht11_io spi_sclk_o spi_mosi_o spi_miso_i spi_ss_n_o i2c_scl_io i2c_sda_io} {
        require_one [get_bd_ports $port_name -quiet] "BD external port $port_name"
    }
    require_one [get_bd_pins rstn_inv_0/Op1 -quiet] "rstn_inv_0/Op1"
    require_one [get_bd_pins rstn_inv_0/Res -quiet] "rstn_inv_0/Res"
    require_one [get_bd_pins proc_sys_reset_0/ext_reset_in -quiet] "proc_sys_reset_0/ext_reset_in"

    set xdc_in_project [get_files -of_objects [get_filesets constrs_1] -quiet $xdc_path]
    if {[llength $xdc_in_project] != 1} {
        fail "Basys3 XDC is not present exactly once in constrs_1: $xdc_in_project"
    }

    add_summary "Project open: PASS"
    add_summary "Required BD cells: PASS"
    add_summary "Required BD external ports: PASS"
    add_summary "Basys3 XDC in constrs_1: PASS"

    validate_bd_design
    add_summary "validate_bd_design: PASS"
    save_bd_design

    set bd_file [require_one [get_files $bd_path -quiet] "BD file in project"]
    generate_target all $bd_file
    set wrapper_rc [catch {set wrapper_files [make_wrapper -files $bd_file -top -force]} wrapper_msg]
    if {$wrapper_rc == 0 && [llength $wrapper_files] > 0} {
        foreach wrapper_file $wrapper_files {
            if {[llength [get_files -quiet $wrapper_file]] == 0} {
                add_files -norecurse $wrapper_file
            }
        }
        add_summary "HDL wrapper refresh: PASS"
    } else {
        add_summary "HDL wrapper refresh: skipped or unchanged ($wrapper_msg)"
    }
    update_compile_order -fileset sources_1
    if {[llength [info commands save_project]] > 0} {
        save_project
    }

    add_summary "Resetting synth_1 and impl_1 runs for a fresh build"
    catch {reset_run synth_1} reset_synth_msg
    catch {reset_run impl_1} reset_impl_msg

    add_summary "Synthesis: RUN"
    launch_runs synth_1 -jobs $jobs
    wait_on_run synth_1
    check_run_complete synth_1 "Synthesis"
    open_run synth_1
    report_utilization -file [file join $report_dir synth_utilization.rpt] -force
    set synth_timing_report [file join $report_dir synth_timing_summary.rpt]
    catch {file delete -force $synth_timing_report}
    report_timing_summary -file $synth_timing_report -delay_type max -report_unconstrained -check_timing_verbose
    close_design
    add_summary "Synthesis reports: PASS"

    add_summary "Implementation through route_design: RUN"
    launch_runs impl_1 -to_step route_design -jobs $jobs
    wait_on_run impl_1
    check_run_complete impl_1 "Implementation"
    open_run impl_1
    set impl_timing_report [file join $report_dir impl_timing_summary.rpt]
    catch {file delete -force $impl_timing_report}
    report_timing_summary -file $impl_timing_report -delay_type max -report_unconstrained -check_timing_verbose
    report_utilization -file [file join $report_dir impl_utilization.rpt] -force
    set impl_drc_report [file join $report_dir impl_drc.rpt]
    catch {file delete -force $impl_drc_report}
    report_drc -file $impl_drc_report
    set power_report [file join $report_dir power_estimate.rpt]
    catch {file delete -force $power_report}
    set power_rc [catch {report_power -file $power_report} power_msg]
    if {$power_rc != 0} {
        write_lines [file join $report_dir power_estimate.rpt] [list "report_power failed or unavailable:" $power_msg]
        add_summary "Power report: FAILED ($power_msg)"
    } else {
        add_summary "Power report: PASS"
    }

    set wns [get_path_slack_or_na max]
    set whs [get_path_slack_or_na min]
    array set drc_counts [collect_drc_counts]
    add_summary "Implementation reports: PASS"
    add_summary "Timing WNS from get_timing_paths: $wns"
    add_summary "Timing WHS from get_timing_paths: $whs"
    add_summary "DRC total violations: $drc_counts(TOTAL)"
    add_summary "DRC ERROR count: $drc_counts(ERROR)"
    add_summary "DRC CRITICAL WARNING count: $drc_counts(CRITICAL_WARNING)"
    add_summary "DRC WARNING count: $drc_counts(WARNING)"

    if {![numeric_nonnegative_or_na $wns]} {
        fail "Timing failed: WNS is negative ($wns). Bitstream/XSA export intentionally skipped."
    }
    if {![numeric_nonnegative_or_na $whs]} {
        fail "Timing failed: WHS is negative ($whs). Bitstream/XSA export intentionally skipped."
    }
    if {$drc_counts(ERROR) > 0 || $drc_counts(CRITICAL_WARNING) > 0} {
        fail "DRC failed: ERROR=$drc_counts(ERROR), CRITICAL WARNING=$drc_counts(CRITICAL_WARNING). Bitstream/XSA export intentionally skipped."
    }
    close_design

    add_summary "Bitstream generation: RUN"
    launch_runs impl_1 -to_step write_bitstream -jobs $jobs
    wait_on_run impl_1
    check_run_complete impl_1 "Bitstream"
    open_run impl_1
    set source_bit [copy_first_bitstream $impl_dir $export_bit]
    add_summary "Source bitstream: $source_bit"
    add_summary "Exported bitstream: $export_bit"

    write_hw_platform -fixed -include_bit -force -file $export_xsa
    if {![file exists $export_xsa]} {
        fail "XSA export did not create expected file: $export_xsa"
    }
    add_summary "Exported XSA: $export_xsa"
    add_summary "XSA include bit: yes"

    add_summary "RESULT: PASS"
    write_build_summary
    close_design
    close_project
} err opts]} {
    add_summary "RESULT: FAIL"
    add_summary "FAILURE: $err"
    write_build_summary
    catch {close_design}
    catch {close_project}
    puts stderr "ERROR: $err"
    puts stderr [dict get $opts -errorinfo]
    exit 1
}

exit 0

