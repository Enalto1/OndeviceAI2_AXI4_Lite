# Apply Basys3 XDC constraints to the Prompt 21 MicroBlaze AXI SoC project.
# Vivado 2020.2 batch command from project root:
# D:/Xilinx/Vivado/2020.2/bin/vivado.bat -mode batch -source vivado/scripts/apply_basys3_xdc.tcl

proc fail {msg} {
    puts stderr "ERROR: $msg"
    exit 1
}

proc require_file {path label} {
    if {![file exists $path]} {
        fail "$label not found: $path"
    }
}

proc write_lines {path lines} {
    set fh [open $path w]
    foreach line $lines {
        puts $fh $line
    }
    close $fh
}

proc prop_exists {obj prop_name} {
    expr {[lsearch -exact [list_property $obj] $prop_name] >= 0}
}

proc get_prop_or_na {obj prop_name} {
    if {[prop_exists $obj $prop_name]} {
        return [get_property $prop_name $obj]
    }
    return "N/A"
}

proc set_prop_if_changed {obj prop_name value} {
    if {![prop_exists $obj $prop_name]} {
        return 0
    }
    set old [get_property $prop_name $obj]
    if {$old eq $value} {
        return 0
    }
    set_property $prop_name $value $obj
    return 1
}

proc disconnect_object_nets {objects} {
    foreach obj $objects {
        set nets [get_bd_nets -quiet -of_objects $obj]
        if {[llength $nets] > 0} {
            delete_bd_objs $nets
        }
    }
}

proc connection_exists {obj_a obj_b} {
    set nets [get_bd_nets -quiet -of_objects $obj_a]
    foreach net $nets {
        set pins [get_bd_pins -quiet -of_objects $net]
        set ports [get_bd_ports -quiet -of_objects $net]
        if {[lsearch -exact $pins $obj_b] >= 0} {
            return 1
        }
        if {[lsearch -exact $ports $obj_b] >= 0} {
            return 1
        }
    }
    return 0
}

proc expand_port_decl {name left right} {
    set out [list]
    if {$left eq "" || $right eq ""} {
        lappend out $name
        return $out
    }
    if {$left >= $right} {
        for {set i $right} {$i <= $left} {incr i} {
            lappend out [format "%s\[%d\]" $name $i]
        }
    } else {
        for {set i $left} {$i <= $right} {incr i} {
            lappend out [format "%s\[%d\]" $name $i]
        }
    }
    return $out
}

proc read_wrapper_ports {wrapper_path} {
    set fh [open $wrapper_path r]
    set text [read $fh]
    close $fh
    set ports [dict create]
    foreach line [split $text "\n"] {
        set s [string trim $line]
        set dir ""
        set left ""
        set right ""
        set names ""
        if {[regexp {^(input|output|inout)\s+\[([0-9]+):([0-9]+)\]\s*([^;]+);} $s -> dir left right names]} {
            foreach raw_name [split $names ","] {
                set name [string trim $raw_name]
                foreach expanded [expand_port_decl $name $left $right] {
                    dict set ports $expanded $dir
                }
            }
        } elseif {[regexp {^(input|output|inout)\s+([^;]+);} $s -> dir names]} {
            foreach raw_name [split $names ","] {
                set name [string trim $raw_name]
                dict set ports $name $dir
            }
        }
    }
    return $ports
}

proc read_xdc_package_pins {xdc_path} {
    set fh [open $xdc_path r]
    set text [read $fh]
    close $fh
    set entries [list]
    foreach line [split $text "\n"] {
        set s [string trim $line]
        if {[string first "set_property PACKAGE_PIN " $s] == 0} {
            set tokens [regexp -all -inline {\S+} $s]
            if {[llength $tokens] >= 5} {
                set pin [lindex $tokens 2]
                set raw_port [lindex $tokens 4]
                set raw_len [string length $raw_port]
                if {$raw_len >= 4} {
                    set port [string range $raw_port 1 [expr {$raw_len - 3}]]
                    lappend entries [list $port $pin]
                }
            }
        }
    }
    return $entries
}

proc xdc_has_clock {xdc_path clock_port} {
    set fh [open $xdc_path r]
    set text [read $fh]
    close $fh
    foreach line [split $text "\n"] {
        set s [string trim $line]
        if {[string first "create_clock" $s] == 0 && [string first $clock_port $s] >= 0} {
            return 1
        }
    }
    return 0
}

proc validate_xdc_against_wrapper {xdc_path wrapper_path report_dir} {
    set wrapper_ports [read_wrapper_ports $wrapper_path]
    set pin_entries [read_xdc_package_pins $xdc_path]
    set errors [list]
    array set pin_to_ports {}
    array set port_to_pins {}

    set port_lines [list "Port\tDirection\tPackagePin\tStatus"]
    foreach entry $pin_entries {
        lassign $entry port pin
        if {![dict exists $wrapper_ports $port]} {
            lappend errors "XDC references missing top-level port: $port"
            lappend port_lines "$port\tN/A\t$pin\tMISSING"
        } else {
            lappend port_lines "$port\t[dict get $wrapper_ports $port]\t$pin\tPASS"
        }
        lappend pin_to_ports($pin) $port
        lappend port_to_pins($port) $pin
    }

    set pin_lines [list "PackagePin\tPorts\tStatus"]
    foreach pin [lsort [array names pin_to_ports]] {
        set ports [lsort -unique $pin_to_ports($pin)]
        if {[llength $ports] > 1} {
            lappend errors "Duplicate PACKAGE_PIN assignment $pin -> [join $ports ,]"
            lappend pin_lines "$pin\t[join $ports ,]\tDUPLICATE"
        } else {
            lappend pin_lines "$pin\t[join $ports ,]\tPASS"
        }
    }

    foreach port [lsort [array names port_to_pins]] {
        set pins [lsort -unique $port_to_pins($port)]
        if {[llength $pins] > 1} {
            lappend errors "Port assigned to multiple PACKAGE_PIN values $port -> [join $pins ,]"
        }
    }

    if {![xdc_has_clock $xdc_path "clk_100mhz_i"]} {
        lappend errors "Missing create_clock constraint for clk_100mhz_i"
    }

    set required_ports [list]
    foreach scalar {clk_100mhz_i reset_i uart_rxd_i uart_txd_o sr04_trig_o sr04_echo_i dht11_io spi_sclk_o spi_mosi_o spi_miso_i spi_ss_n_o i2c_scl_io i2c_sda_io} {
        lappend required_ports $scalar
    }
    foreach base {sw_i led_o} {
        for {set i 0} {$i < 16} {incr i} { lappend required_ports [format "%s\[%d\]" $base $i] }
    }
    for {set i 0} {$i < 5} {incr i} { lappend required_ports [format "btn_i\[%d\]" $i] }
    for {set i 0} {$i < 8} {incr i} { lappend required_ports [format "fnd_data_o\[%d\]" $i] }
    for {set i 0} {$i < 4} {incr i} { lappend required_ports [format "fnd_com_o\[%d\]" $i] }
    foreach port $required_ports {
        if {![info exists port_to_pins($port)]} {
            lappend errors "Required top-level port is unconstrained: $port"
        }
    }

    write_lines [file join $report_dir basys3_xdc_port_check.tsv] $port_lines
    write_lines [file join $report_dir basys3_xdc_pin_check.tsv] $pin_lines
    return $errors
}

set script_path [file normalize [info script]]
set script_dir [file dirname $script_path]
set root_dir [file normalize [file join $script_dir .. ..]]
set vivado_exe "D:/Xilinx/Vivado/2020.2/bin/vivado.bat"
set project_path [file join $root_dir vivado basys3 microblaze_axi_soc microblaze_axi_soc.xpr]
set bd_path [file join $root_dir vivado basys3 microblaze_axi_soc microblaze_axi_soc.srcs sources_1 bd microblaze_axi_soc_bd microblaze_axi_soc_bd.bd]
set wrapper_path [file join $root_dir vivado basys3 microblaze_axi_soc microblaze_axi_soc.gen sources_1 bd microblaze_axi_soc_bd hdl microblaze_axi_soc_bd_wrapper.v]
set xdc_path [file join $root_dir constraints basys3 basys3_axi_soc.xdc]
set report_dir [file join $root_dir vivado basys3 microblaze_axi_soc reports]
file mkdir $report_dir

require_file $project_path "Vivado project"
require_file $bd_path "Block design"
require_file $wrapper_path "HDL wrapper"
require_file $xdc_path "Basys3 XDC"

if {[catch {
    open_project $project_path
    open_bd_design $bd_path

    set bd_modified 0
    set xdc_added 0
    set wrapper_regenerated 0

    set reset_port [get_bd_ports reset_i -quiet]
    if {[llength $reset_port] != 1} {
        error "Expected exactly one BD reset_i port, found [llength $reset_port]"
    }
    set proc_reset [get_bd_cells proc_sys_reset_0 -quiet]
    if {[llength $proc_reset] != 1} {
        error "Expected exactly one proc_sys_reset_0 cell, found [llength $proc_reset]"
    }

    set reset_before_port_polarity [get_prop_or_na $reset_port CONFIG.POLARITY]
    set reset_before_ext_high [get_prop_or_na $proc_reset CONFIG.C_EXT_RESET_HIGH]

    if {[set_prop_if_changed $reset_port CONFIG.POLARITY ACTIVE_LOW]} {
        set bd_modified 1
    }
    set direct_ext_reset_change "not used; CONFIG.C_EXT_RESET_HIGH is read-only in the opened BD project"

    set old_inverter [get_bd_cells reset_i_active_low_to_high -quiet]
    if {[llength $old_inverter] > 0} {
        delete_bd_objs $old_inverter
        set bd_modified 1
    }

    set inverter_name rstn_inv_0
    set inverter [get_bd_cells $inverter_name -quiet]
    if {[llength $inverter] == 0} {
        set inverter [create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:* $inverter_name]
        set bd_modified 1
    }
    if {[set_prop_if_changed $inverter CONFIG.C_OPERATION not]} {
        set bd_modified 1
    }
    if {[set_prop_if_changed $inverter CONFIG.C_SIZE 1]} {
        set bd_modified 1
    }

    set reset_to_inv_ok [connection_exists [get_bd_ports reset_i] [get_bd_pins $inverter_name/Op1]]
    set inv_to_proc_ok [connection_exists [get_bd_pins $inverter_name/Res] [get_bd_pins proc_sys_reset_0/ext_reset_in]]
    if {!$reset_to_inv_ok || !$inv_to_proc_ok} {
        disconnect_object_nets [list [get_bd_ports reset_i] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins $inverter_name/Op1] [get_bd_pins $inverter_name/Res]]
        connect_bd_net [get_bd_ports reset_i] [get_bd_pins $inverter_name/Op1]
        connect_bd_net [get_bd_pins $inverter_name/Res] [get_bd_pins proc_sys_reset_0/ext_reset_in]
        set bd_modified 1
    }

    set reset_after_port_polarity [get_prop_or_na $reset_port CONFIG.POLARITY]
    set reset_after_ext_high [get_prop_or_na $proc_reset CONFIG.C_EXT_RESET_HIGH]
    if {$reset_after_port_polarity ne "ACTIVE_LOW"} {
        error "reset_i CONFIG.POLARITY is $reset_after_port_polarity, expected ACTIVE_LOW"
    }
    if {$reset_after_ext_high ne "1"} {
        error "proc_sys_reset_0 CONFIG.C_EXT_RESET_HIGH is $reset_after_ext_high, expected 1 when using inverter fallback"
    }

    set existing_xdc [get_files -quiet $xdc_path]
    if {[llength $existing_xdc] == 0} {
        add_files -fileset constrs_1 -norecurse $xdc_path
        set xdc_added 1
    }
    set xdc_in_project [get_files -of_objects [get_filesets constrs_1] -quiet $xdc_path]
    if {[llength $xdc_in_project] == 0} {
        error "XDC was not added to constrs_1: $xdc_path"
    }

    validate_bd_design
    if {$bd_modified} {
        save_bd_design
        make_wrapper -files [get_files $bd_path] -top -force
        set wrapper_regenerated 1
    }
    update_compile_order -fileset sources_1
    if {[llength [info commands save_project]] > 0} {
        save_project
    }

    set validation_errors [validate_xdc_against_wrapper $xdc_path $wrapper_path $report_dir]
    if {[llength $validation_errors] != 0} {
        error [join $validation_errors "\n"]
    }

    set summary [list]
    lappend summary "Vivado executable: $vivado_exe"
    lappend summary "Vivado version: [version -short]"
    lappend summary "Project: $project_path"
    lappend summary "BD: microblaze_axi_soc_bd"
    lappend summary "XDC: $xdc_path"
    lappend summary "XDC added to constrs_1: PASS"
    lappend summary "XDC added on this run: $xdc_added"
    lappend summary "Top wrapper: $wrapper_path"
    lappend summary "reset_i physical pin: G2 PMOD JA4 external active-low reset"
    lappend summary "reset_i external board polarity: active-low"
    lappend summary "reset_i BD port polarity before: $reset_before_port_polarity"
    lappend summary "proc_sys_reset_0 CONFIG.C_EXT_RESET_HIGH before: $reset_before_ext_high"
    lappend summary "Direct proc_sys_reset polarity change: $direct_ext_reset_change"
    lappend summary "Reset inverter present: yes, $inverter_name util_vector_logic NOT"
    lappend summary "reset_i BD port polarity after: $reset_after_port_polarity"
    lappend summary "proc_sys_reset_0 CONFIG.C_EXT_RESET_HIGH after: $reset_after_ext_high"
    lappend summary "BD modified on this run: $bd_modified"
    lappend summary "HDL wrapper regenerated on this run: $wrapper_regenerated"
    lappend summary "Reset can be revised by editing the reset section of basys3_axi_soc.xdc or copying a snippet from constraints/basys3/reset_options"
    lappend summary "validate_bd_design: PASS"
    lappend summary "XDC port existence check: PASS"
    lappend summary "Duplicate PACKAGE_PIN check: PASS"
    lappend summary "Clock constraint check: PASS"
    lappend summary "Synthesis: skipped"
    lappend summary "Implementation: skipped"
    lappend summary "Bitstream: skipped"
    write_lines [file join $report_dir basys3_xdc_apply_summary.txt] $summary

    set reset_lines [list]
    lappend reset_lines "External reset port: reset_i"
    lappend reset_lines "Physical pin: G2 PMOD JA4 external active-low reset"
    lappend reset_lines "Board active level: active-low, asserted when the external JA4/G2 reset button pulls the signal to GND"
    lappend reset_lines "XDC PULLUP: true"
    lappend reset_lines "BD reset_i CONFIG.POLARITY: $reset_after_port_polarity"
    lappend reset_lines "proc_sys_reset_0 CONFIG.C_EXT_RESET_HIGH: $reset_after_ext_high"
    lappend reset_lines "Connection: reset_i -> rstn_inv_0/Op1 -> rstn_inv_0/Res -> proc_sys_reset_0/ext_reset_in"
    lappend reset_lines "Direct proc_sys_reset external reset polarity change: unavailable/read-only in this project"
    lappend reset_lines "BD reset adapter present: yes, rstn_inv_0 util_vector_logic NOT inverter"
    lappend reset_lines "BD modified on this run: $bd_modified"
    lappend reset_lines "HDL wrapper regenerated on this run: $wrapper_regenerated"
    lappend reset_lines "Normal GPIO buttons remain mapped to btn_i[4:0]"
    lappend reset_lines "Revision snippets: constraints/basys3/reset_options"
    write_lines [file join $report_dir basys3_reset_policy_actual.txt] $reset_lines

    close_project
} err opts]} {
    puts stderr "ERROR: $err"
    puts stderr [dict get $opts -errorinfo]
    exit 1
}

exit 0

