# Common Vivado 2020.2 local IP packaging helpers for custom AXI4-Lite peripherals.
# Source this file from package_axi_* scripts or package_all_custom_ip.tcl.

proc custom_ip_project_root {} {
    set script_dir [file dirname [file normalize [info script]]]
    return [file normalize [file join $script_dir .. ..]]
}

proc custom_ip_require_file {path description} {
    if {![file exists $path]} {
        error "$description not found: $path"
    }
}

proc custom_ip_get_first {objects} {
    if {[llength $objects] == 0} {
        return ""
    }
    return [lindex $objects 0]
}

proc custom_ip_find_bus_interface {core candidates} {
    foreach candidate $candidates {
        set found [ipx::get_bus_interfaces $candidate -of_objects $core -quiet]
        if {[llength $found] > 0} {
            return [lindex $found 0]
        }
    }
    return ""
}

proc custom_ip_associate_clock_reset {core axi_if_name} {
    set clk_if [custom_ip_find_bus_interface $core [list s00_axi_aclk S00_AXI_ACLK]]
    if {$clk_if eq ""} {
        catch {ipx::infer_bus_interface s00_axi_aclk xilinx.com:signal:clock_rtl:1.0 $core} infer_clk_msg
        set clk_if [custom_ip_find_bus_interface $core [list s00_axi_aclk S00_AXI_ACLK]]
    }

    set rst_if [custom_ip_find_bus_interface $core [list s00_axi_aresetn S00_AXI_ARESETN]]
    if {$rst_if eq ""} {
        catch {ipx::infer_bus_interface s00_axi_aresetn xilinx.com:signal:reset_rtl:1.0 $core} infer_rst_msg
        set rst_if [custom_ip_find_bus_interface $core [list s00_axi_aresetn S00_AXI_ARESETN]]
    }

    if {$clk_if ne ""} {
        catch {ipx::associate_bus_interfaces -busif $axi_if_name -clock s00_axi_aclk $core}
    }
}

proc custom_ip_package {cfg} {
    set project_root [custom_ip_project_root]
    set ip_repo_dir [file join $project_root vivado ip_repo]
    set name [dict get $cfg name]
    set top [dict get $cfg top]
    set files [dict get $cfg files]
    set sv_files [dict get $cfg sv_files]
    set external_ports [dict get $cfg external_ports]
    set ip_dir [file join $ip_repo_dir $name]

    puts "============================================================"
    puts "Packaging $name"
    puts "Project root: $project_root"
    puts "Output dir  : $ip_dir"
    puts "============================================================"

    foreach rel $files {
        custom_ip_require_file [file join $project_root $rel] "Source file"
    }

    file mkdir $ip_repo_dir
    if {[file exists $ip_dir]} {
        file delete -force $ip_dir
    }
    file mkdir $ip_dir

    if {[llength [get_projects -quiet]] > 0} {
        close_project
    }

    create_project ${name}_packaging -in_memory -part xc7a35tcpg236-1 -force
    set_property target_language Verilog [current_project]
    set_property simulator_language Mixed [current_project]

    set abs_files [list]
    foreach rel $files {
        lappend abs_files [file normalize [file join $project_root $rel]]
    }
    add_files -norecurse $abs_files

    foreach rel $sv_files {
        set abs_sv [file normalize [file join $project_root $rel]]
        set_property file_type SystemVerilog [get_files $abs_sv]
    }

    set_property top $top [current_fileset]

    ipx::package_project -root_dir $ip_dir -vendor user.org -library user -taxonomy /UserIP -import_files -force_update_compile_order -force
    set core [ipx::current_core]
    set_property vendor user.org $core
    set_property library user $core
    set_property name $name $core
    set_property display_name $name $core
    set_property description "Custom AXI4-Lite peripheral $name packaged from project RTL" $core
    set_property version 1.0 $core
    set_property taxonomy {/UserIP} $core

    set axi_if ""
    catch {ipx::infer_bus_interface s00_axi xilinx.com:interface:aximm_rtl:1.0 $core} infer_axi_msg
    set axi_if [custom_ip_find_bus_interface $core [list s00_axi S00_AXI]]
    if {$axi_if eq ""} {
        catch {ipx::infer_bus_interface S00_AXI xilinx.com:interface:aximm_rtl:1.0 $core} infer_axi_upper_msg
        set axi_if [custom_ip_find_bus_interface $core [list S00_AXI s00_axi]]
    }
    if {$axi_if eq ""} {
        error "$name: failed to infer AXI4-Lite bus interface from s00_axi_* ports"
    }
    set_property name S00_AXI $axi_if
    set axi_if [custom_ip_find_bus_interface $core [list S00_AXI]]
    set_property interface_mode slave $axi_if

    custom_ip_associate_clock_reset $core S00_AXI

    foreach port_name $external_ports {
        set port_obj [ipx::get_ports $port_name -of_objects $core -quiet]
        if {[llength $port_obj] == 0} {
            error "$name: expected external port missing from packaged core: $port_name"
        }
    }

    set axi_if [custom_ip_find_bus_interface $core [list S00_AXI]]
    if {$axi_if eq ""} {
        error "$name: S00_AXI interface missing after metadata update"
    }

    ipx::update_checksums $core
    set integrity_status [catch {ipx::check_integrity $core} integrity_msg]
    if {$integrity_status != 0} {
        puts "WARNING: $name ipx::check_integrity returned: $integrity_msg"
    }
    ipx::save_core $core

    set component_xml [file join $ip_dir component.xml]
    custom_ip_require_file $component_xml "Packaged component.xml"

    close_project
    puts "PACKAGED $name -> $component_xml"
}

