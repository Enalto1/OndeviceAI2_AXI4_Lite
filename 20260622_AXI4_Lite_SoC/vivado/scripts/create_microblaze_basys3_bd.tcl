# Create a Basys3-targeted MicroBlaze AXI4-Lite block design using packaged local IP.
# Vivado 2020.2 batch entry point. Do not run synthesis, implementation, bitstream, or export hardware.

set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir .. ..]]
set vivado_dir [file join $project_root vivado]
set ip_repo_dir [file join $vivado_dir ip_repo]
set basys3_dir [file join $vivado_dir basys3]
set project_dir [file join $basys3_dir microblaze_axi_soc]
set reports_dir [file join $project_dir reports]
set project_name microblaze_axi_soc
set bd_name microblaze_axi_soc_bd
set part_name xc7a35tcpg236-1
set requested_board_part ""
set selected_board_part "part-only: board_part unavailable or not selected"

proc require_file {path description} {
    if {![file exists $path]} {
        error "$description not found: $path"
    }
}

proc require_nonempty {objects description} {
    if {[llength $objects] == 0} {
        error "$description not found"
    }
    return $objects
}

proc set_property_if_present {object property_name property_value} {
    if {[lsearch -exact [list_property $object] $property_name] >= 0} {
        set_property $property_name $property_value $object
    }
}

proc connect_if_exists {from_obj to_obj description} {
    require_nonempty $from_obj "$description source"
    require_nonempty $to_obj "$description sink"
    connect_bd_net $from_obj $to_obj
}

proc get_slave_addr_seg {cell_name if_name} {
    set intf_pin [get_bd_intf_pins ${cell_name}/${if_name} -quiet]
    if {[llength $intf_pin] == 0} {
        error "Missing interface pin ${cell_name}/${if_name}"
    }
    set segs [get_bd_addr_segs -of_objects $intf_pin -quiet]
    if {[llength $segs] != 1} {
        error "Expected one address segment for ${cell_name}/${if_name}, found [llength $segs]: $segs"
    }
    return [lindex $segs 0]
}

proc format_hex32 {value} {
    return [format "0x%08X" [expr {$value & 0xffffffff}]]
}

proc normalize_hex {value} {
    return [format_hex32 [expr {$value}]]
}

proc write_lines {path lines} {
    set fp [open $path w]
    foreach line $lines {
        puts $fp $line
    }
    close $fp
}
proc normalize_packaged_ip_clock_metadata {ip_repo_dir ip_names} {
    set fix_count 0
    foreach ip_name $ip_names {
        set component_xml [file join $ip_repo_dir $ip_name component.xml]
        require_file $component_xml "Packaged component.xml for $ip_name"
        set fp [open $component_xml r]
        set text [read $fp]
        close $fp
        if {[string first "s00_axi:S00_AXI" $text] >= 0} {
            set text [string map [list "s00_axi:S00_AXI" "S00_AXI"] $text]
            set out [open $component_xml w]
            puts -nonewline $out $text
            close $out
            incr fix_count
            puts "Normalized ASSOCIATED_BUSIF metadata in $component_xml"
        }
    }
    return $fix_count
}
proc connect_clock_to_pins {clk_port pin_patterns} {
    set seen [list]
    foreach pattern $pin_patterns {
        foreach pin [get_bd_pins $pattern -quiet] {
            if {[lsearch -exact $seen $pin] >= 0} {
                continue
            }
            lappend seen $pin
            if {[llength [get_bd_nets -of_objects $pin -quiet]] == 0} {
                connect_bd_net [get_bd_ports $clk_port] $pin
            }
        }
    }
}

proc connect_resetn_to_pins {reset_pin pin_patterns} {
    set seen [list]
    foreach pattern $pin_patterns {
        foreach pin [get_bd_pins $pattern -quiet] {
            if {[lsearch -exact $seen $pin] >= 0} {
                continue
            }
            lappend seen $pin
            if {[llength [get_bd_nets -of_objects $pin -quiet]] == 0} {
                connect_bd_net $reset_pin $pin
            }
        }
    }
}

puts "============================================================"
puts "Create MicroBlaze Basys3 AXI SoC block design"
puts "Project root: $project_root"
puts "Project dir : $project_dir"
puts "IP repo     : $ip_repo_dir"
puts "============================================================"

require_file $ip_repo_dir "Local IP repository"
set custom_ip_names {axi_gpio_core axi_fnd_core axi_timer_core axi_sensor_core axi_spi_core axi_i2c_core}
foreach ip_name $custom_ip_names {
    require_file [file join $ip_repo_dir $ip_name component.xml] "Packaged component.xml for $ip_name"
}
set packaged_metadata_fix_count [normalize_packaged_ip_clock_metadata $ip_repo_dir $custom_ip_names]

file mkdir $basys3_dir
if {[file exists $project_dir]} {
    file delete -force $project_dir
}
file mkdir $project_dir
file mkdir $reports_dir

create_project $project_name $project_dir -part $part_name -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

set board_parts [get_board_parts -quiet *basys3*]
if {[llength $board_parts] > 0} {
    set selected_board_part [lindex $board_parts 0]
    set_property board_part $selected_board_part [current_project]
}

set_property ip_repo_paths $ip_repo_dir [current_project]
update_ip_catalog -rebuild

foreach ip_name $custom_ip_names {
    set ipdefs [get_ipdefs -all "user.org:user:${ip_name}:1.0" -quiet]
    if {[llength $ipdefs] == 0} {
        error "Packaged IP not visible in catalog: user.org:user:${ip_name}:1.0"
    }
}

create_bd_design $bd_name
current_bd_design $bd_name

# External clock and reset. Pin assignments are intentionally deferred to the XDC step.
set clk_port [create_bd_port -dir I -type clk -freq_hz 100000000 clk_100mhz_i]
set_property CONFIG.FREQ_HZ 100000000 $clk_port
set rst_port [create_bd_port -dir I -type rst reset_i]
set_property CONFIG.POLARITY ACTIVE_HIGH $rst_port

# MicroBlaze processor with local instruction/data LMB and AXI data peripheral master.
set microblaze_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:* microblaze_0]
set_property -dict [list \
    CONFIG.C_DEBUG_ENABLED {1} \
    CONFIG.C_D_AXI {1} \
    CONFIG.C_D_LMB {1} \
    CONFIG.C_I_LMB {1} \
    CONFIG.C_USE_BARREL {1} \
    CONFIG.C_USE_HW_MUL {1} \
    CONFIG.C_USE_MSR_INSTR {1} \
    CONFIG.C_USE_PCMP_INSTR {1} \
] $microblaze_0

set mdm_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:* mdm_0]
set_property_if_present $mdm_0 CONFIG.C_USE_BSCAN 2

set proc_sys_reset_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:* proc_sys_reset_0]
set xlconstant_reset_locked [create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:* xlconstant_reset_locked]
set_property -dict [list CONFIG.CONST_VAL {1} CONFIG.CONST_WIDTH {1}] $xlconstant_reset_locked

set ilmb_v10 [create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:* ilmb_v10]
set dlmb_v10 [create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:* dlmb_v10]
set ilmb_bram_if_cntlr [create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:* ilmb_bram_if_cntlr]
set dlmb_bram_if_cntlr [create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:* dlmb_bram_if_cntlr]
set_property -dict [list CONFIG.C_ECC {0}] $ilmb_bram_if_cntlr
set_property -dict [list CONFIG.C_ECC {0}] $dlmb_bram_if_cntlr
set lmb_bram [create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:* lmb_bram]
set_property -dict [list \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.use_bram_block {BRAM_Controller} \
    CONFIG.Assume_Synchronous_Clk {true} \
] $lmb_bram

# AXI fabric and memory-mapped slaves.
set smartconnect_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:* smartconnect_0]
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {7}] $smartconnect_0

set axi_uartlite_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:* axi_uartlite_0]
set_property_if_present $axi_uartlite_0 CONFIG.C_BAUDRATE 9600
set_property_if_present $axi_uartlite_0 CONFIG.C_DATA_BITS 8
set_property_if_present $axi_uartlite_0 CONFIG.C_USE_PARITY 0

set axi_gpio_core_0 [create_bd_cell -type ip -vlnv user.org:user:axi_gpio_core:1.0 axi_gpio_core_0]
set axi_fnd_core_0 [create_bd_cell -type ip -vlnv user.org:user:axi_fnd_core:1.0 axi_fnd_core_0]
set axi_timer_core_0 [create_bd_cell -type ip -vlnv user.org:user:axi_timer_core:1.0 axi_timer_core_0]
set axi_sensor_core_0 [create_bd_cell -type ip -vlnv user.org:user:axi_sensor_core:1.0 axi_sensor_core_0]
set axi_spi_core_0 [create_bd_cell -type ip -vlnv user.org:user:axi_spi_core:1.0 axi_spi_core_0]
set axi_i2c_core_0 [create_bd_cell -type ip -vlnv user.org:user:axi_i2c_core:1.0 axi_i2c_core_0]


# Interface connections.
connect_bd_intf_net [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
connect_bd_intf_net [get_bd_intf_pins dlmb_v10/LMB_Sl_0] [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB]
connect_bd_intf_net [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
connect_bd_intf_net [get_bd_intf_pins ilmb_v10/LMB_Sl_0] [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB]
connect_bd_intf_net [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins microblaze_0/DEBUG] [get_bd_intf_pins mdm_0/MBDEBUG_0]
connect_bd_intf_net [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins smartconnect_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_uartlite_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins axi_gpio_core_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins axi_fnd_core_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M03_AXI] [get_bd_intf_pins axi_timer_core_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M04_AXI] [get_bd_intf_pins axi_sensor_core_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M05_AXI] [get_bd_intf_pins axi_spi_core_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M06_AXI] [get_bd_intf_pins axi_i2c_core_0/S00_AXI]

# Clock connections.
connect_clock_to_pins clk_100mhz_i [list \
    microblaze_0/Clk \
    mdm_0/S_AXI_ACLK \
    proc_sys_reset_0/slowest_sync_clk \
    ilmb_v10/LMB_Clk \
    dlmb_v10/LMB_Clk \
    ilmb_bram_if_cntlr/LMB_Clk \
    dlmb_bram_if_cntlr/LMB_Clk \
    smartconnect_0/aclk \
    axi_uartlite_0/s_axi_aclk \
    axi_gpio_core_0/s00_axi_aclk \
    axi_fnd_core_0/s00_axi_aclk \
    axi_timer_core_0/s00_axi_aclk \
    axi_sensor_core_0/s00_axi_aclk \
    axi_spi_core_0/s00_axi_aclk \
    axi_i2c_core_0/s00_axi_aclk \
]

# Reset connections.
connect_bd_net [get_bd_ports reset_i] [get_bd_pins proc_sys_reset_0/ext_reset_in]
connect_bd_net [get_bd_pins xlconstant_reset_locked/dout] [get_bd_pins proc_sys_reset_0/dcm_locked]
connect_bd_net [get_bd_pins mdm_0/Debug_SYS_Rst] [get_bd_pins proc_sys_reset_0/mb_debug_sys_rst]
connect_bd_net [get_bd_pins proc_sys_reset_0/mb_reset] [get_bd_pins microblaze_0/Reset]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_reset] \
    [get_bd_pins ilmb_v10/SYS_Rst] \
    [get_bd_pins dlmb_v10/SYS_Rst] \
    [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] \
    [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst]
connect_resetn_to_pins [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [list \
    smartconnect_0/aresetn \
    axi_uartlite_0/s_axi_aresetn \
    axi_gpio_core_0/s00_axi_aresetn \
    axi_fnd_core_0/s00_axi_aresetn \
    axi_timer_core_0/s00_axi_aresetn \
    axi_sensor_core_0/s00_axi_aresetn \
    axi_spi_core_0/s00_axi_aresetn \
    axi_i2c_core_0/s00_axi_aresetn \
]

# UART external ports.
set uart_rxd_i [create_bd_port -dir I uart_rxd_i]
set uart_txd_o [create_bd_port -dir O uart_txd_o]
connect_bd_net [get_bd_ports uart_rxd_i] [get_bd_pins axi_uartlite_0/rx]
connect_bd_net [get_bd_pins axi_uartlite_0/tx] [get_bd_ports uart_txd_o]

# Custom external ports. Exact pin constraints are intentionally deferred.
set led_o [create_bd_port -dir O -from 15 -to 0 led_o]
set sw_i [create_bd_port -dir I -from 15 -to 0 sw_i]
set btn_i [create_bd_port -dir I -from 4 -to 0 btn_i]
connect_bd_net [get_bd_pins axi_gpio_core_0/led_o] [get_bd_ports led_o]
connect_bd_net [get_bd_ports sw_i] [get_bd_pins axi_gpio_core_0/sw_i]
connect_bd_net [get_bd_ports btn_i] [get_bd_pins axi_gpio_core_0/btn_i]

set fnd_com_o [create_bd_port -dir O -from 3 -to 0 fnd_com_o]
set fnd_data_o [create_bd_port -dir O -from 7 -to 0 fnd_data_o]
connect_bd_net [get_bd_pins axi_fnd_core_0/fnd_com_o] [get_bd_ports fnd_com_o]
connect_bd_net [get_bd_pins axi_fnd_core_0/fnd_data_o] [get_bd_ports fnd_data_o]

set sr04_echo_i [create_bd_port -dir I sr04_echo_i]
set sr04_trig_o [create_bd_port -dir O sr04_trig_o]
set dht11_io [create_bd_port -dir IO dht11_io]
connect_bd_net [get_bd_ports sr04_echo_i] [get_bd_pins axi_sensor_core_0/sr04_echo_i]
connect_bd_net [get_bd_pins axi_sensor_core_0/sr04_trig_o] [get_bd_ports sr04_trig_o]
connect_bd_net [get_bd_ports dht11_io] [get_bd_pins axi_sensor_core_0/dht11_io]

set spi_sclk_o [create_bd_port -dir O spi_sclk_o]
set spi_mosi_o [create_bd_port -dir O spi_mosi_o]
set spi_miso_i [create_bd_port -dir I spi_miso_i]
set spi_ss_n_o [create_bd_port -dir O spi_ss_n_o]
connect_bd_net [get_bd_pins axi_spi_core_0/spi_sclk_o] [get_bd_ports spi_sclk_o]
connect_bd_net [get_bd_pins axi_spi_core_0/spi_mosi_o] [get_bd_ports spi_mosi_o]
connect_bd_net [get_bd_ports spi_miso_i] [get_bd_pins axi_spi_core_0/spi_miso_i]
connect_bd_net [get_bd_pins axi_spi_core_0/spi_ss_n_o] [get_bd_ports spi_ss_n_o]

set i2c_scl_io [create_bd_port -dir IO i2c_scl_io]
set i2c_sda_io [create_bd_port -dir IO i2c_sda_io]
connect_bd_net [get_bd_ports i2c_scl_io] [get_bd_pins axi_i2c_core_0/i2c_scl_io]
connect_bd_net [get_bd_ports i2c_sda_io] [get_bd_pins axi_i2c_core_0/i2c_sda_io]

# Exact address map. Ranges are 64 KB for AXI UART Lite and each custom IP.
set addr_rows [list]
lappend addr_rows [list axi_uartlite_0 S_AXI "AXI UART Lite" 0x40600000 0x00010000]
lappend addr_rows [list axi_gpio_core_0 S00_AXI "axi_gpio_core" 0x44A00000 0x00010000]
lappend addr_rows [list axi_fnd_core_0 S00_AXI "axi_fnd_core" 0x44A10000 0x00010000]
lappend addr_rows [list axi_timer_core_0 S00_AXI "axi_timer_core" 0x44A20000 0x00010000]
lappend addr_rows [list axi_sensor_core_0 S00_AXI "axi_sensor_core" 0x44A30000 0x00010000]
lappend addr_rows [list axi_spi_core_0 S00_AXI "axi_spi_core" 0x44A40000 0x00010000]
lappend addr_rows [list axi_i2c_core_0 S00_AXI "axi_i2c_core" 0x44A50000 0x00010000]

set data_space [get_bd_addr_spaces microblaze_0/Data]
set address_report_rows [list "Name\tExpectedBase\tActualBase\tRange\tExpectedHigh\tActualHigh\tStatus\tSegment"]
set address_intervals [list]
foreach row $addr_rows {
    lassign $row cell if_name label base range
    set target_seg [get_slave_addr_seg $cell $if_name]
    set seg_name SEG_${cell}_Reg
    set seg [create_bd_addr_seg -range $range -offset $base $data_space $target_seg $seg_name]
    set actual_base [expr {[get_property OFFSET $seg]}]
    set actual_range [expr {[get_property RANGE $seg]}]
    set expected_high [expr {$base + $range - 1}]
    set actual_high [expr {$actual_base + $actual_range - 1}]
    set status PASS
    if {$actual_base != $base || $actual_range != $range} {
        set status FAIL
    }
    lappend address_intervals [list $label $actual_base $actual_high]
    lappend address_report_rows [format "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" \
        $label [format_hex32 $base] [format_hex32 $actual_base] [format_hex32 $actual_range] \
        [format_hex32 $expected_high] [format_hex32 $actual_high] $status $seg]
}

# Local BRAM mapped at 0x00000000 in instruction and data spaces. 128 KB range.
create_bd_addr_seg -range 0x00020000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
create_bd_addr_seg -range 0x00020000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem

# Check address overlap in the AXI peripheral address plan.
for {set i 0} {$i < [llength $address_intervals]} {incr i} {
    lassign [lindex $address_intervals $i] name_i base_i high_i
    for {set j [expr {$i + 1}]} {$j < [llength $address_intervals]} {incr j} {
        lassign [lindex $address_intervals $j] name_j base_j high_j
        if {($base_i <= $high_j) && ($base_j <= $high_i)} {
            error "Address overlap between $name_i and $name_j"
        }
    }
}

# Validate required cells and ports are present before BD validation.
foreach cell_name {microblaze_0 mdm_0 proc_sys_reset_0 smartconnect_0 axi_uartlite_0 axi_gpio_core_0 axi_fnd_core_0 axi_timer_core_0 axi_sensor_core_0 axi_spi_core_0 axi_i2c_core_0 ilmb_bram_if_cntlr dlmb_bram_if_cntlr lmb_bram} {
    require_nonempty [get_bd_cells $cell_name -quiet] "BD cell $cell_name"
}
foreach port_name {clk_100mhz_i reset_i uart_rxd_i uart_txd_o led_o sw_i btn_i fnd_com_o fnd_data_o sr04_echo_i sr04_trig_o dht11_io spi_sclk_o spi_mosi_o spi_miso_i spi_ss_n_o i2c_scl_io i2c_sda_io} {
    require_nonempty [get_bd_ports $port_name -quiet] "BD external port $port_name"
}

regenerate_bd_layout
set validate_status [catch {validate_bd_design} validate_msg]
if {$validate_status != 0} {
    puts "validate_bd_design FAILED: $validate_msg"
    error $validate_msg
}
puts "validate_bd_design PASS"
save_bd_design

# Generate HDL wrapper without running synthesis/implementation/bitstream.
set bd_file [get_files [file join $project_dir ${project_name}.srcs sources_1 bd $bd_name ${bd_name}.bd]]
set wrapper_status SKIPPED
set wrapper_path ""
set wrapper_rc [catch {
    set wrapper_files [make_wrapper -files $bd_file -top]
    add_files -norecurse $wrapper_files
    set wrapper_status GENERATED
    set wrapper_path $wrapper_files
} wrapper_msg]
if {$wrapper_rc != 0} {
    set wrapper_status "SKIPPED: $wrapper_msg"
}

# Write Vivado-side reports.
file mkdir $reports_dir
set report_bd_addr_rc [catch {report_bd_address -file [file join $reports_dir bd_address_report.txt] -force} report_bd_addr_msg]
if {$report_bd_addr_rc != 0} {
    set manual_addr_report [list]
    lappend manual_addr_report "Vivado report_bd_address unavailable in this environment: $report_bd_addr_msg"
    lappend manual_addr_report "The exact address map below was created from the BD address segment objects immediately after create_bd_addr_seg."
    lappend manual_addr_report ""
    foreach line $address_report_rows {
        lappend manual_addr_report $line
    }
    write_lines [file join $reports_dir bd_address_report.txt] $manual_addr_report
}
write_lines [file join $reports_dir bd_address_map_actual.tsv] $address_report_rows

set cell_lines [list "BD cells"]
foreach c [lsort [get_bd_cells -hier]] {
    lappend cell_lines $c
}
write_lines [file join $reports_dir bd_cells.txt] $cell_lines

set port_lines [list "Port\tDirection\tLeft\tRight\tType"]
foreach p [lsort [get_bd_ports]] {
    set dir [get_property DIR $p]
    set left [get_property LEFT $p]
    set right [get_property RIGHT $p]
    set type [get_property TYPE $p]
    lappend port_lines [format "%s\t%s\t%s\t%s\t%s" [get_property NAME $p] $dir $left $right $type]
}
write_lines [file join $reports_dir bd_external_ports.tsv] $port_lines

set summary_lines [list]
lappend summary_lines "Vivado version: [version -short]"
lappend summary_lines "Project: $project_dir"
lappend summary_lines "Part: $part_name"
lappend summary_lines "Board part: $selected_board_part"
lappend summary_lines "BD: $bd_name"
lappend summary_lines "IP repo: $ip_repo_dir"
lappend summary_lines "Interconnect: smartconnect_0"
lappend summary_lines "validate_bd_design: PASS"
lappend summary_lines "HDL wrapper: $wrapper_status"
lappend summary_lines "HDL wrapper path: $wrapper_path"
lappend summary_lines "Synthesis: skipped"
lappend summary_lines "Implementation: skipped"
lappend summary_lines "Bitstream: skipped"
lappend summary_lines "Packaged IP metadata normalized/verified: [llength $custom_ip_names] component.xml files; modified on this run: $packaged_metadata_fix_count"
write_lines [file join $reports_dir bd_validation_summary.txt] $summary_lines

close_project
puts "============================================================"
puts "MicroBlaze Basys3 BD creation summary"
puts "Project: $project_dir"
puts "Block design: $bd_name"
puts "validate_bd_design: PASS"
puts "HDL wrapper: $wrapper_status"
puts "Address report: [file join $reports_dir bd_address_map_actual.tsv]"
puts "============================================================"
exit 0




