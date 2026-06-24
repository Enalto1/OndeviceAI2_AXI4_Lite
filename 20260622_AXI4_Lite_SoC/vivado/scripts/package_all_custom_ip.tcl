# Package all custom AXI4-Lite peripherals as local Vivado 2020.2 IP.
set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir .. ..]]
set ip_repo_dir [file join $project_root vivado ip_repo]

source [file join $script_dir package_common_custom_ip.tcl]

set ip_names [list \
    axi_gpio_core \
    axi_fnd_core \
    axi_timer_core \
    axi_sensor_core \
    axi_spi_core \
    axi_i2c_core \
]

puts "Package all custom IP"
puts "Project root: $project_root"
puts "IP repo     : $ip_repo_dir"

file mkdir $ip_repo_dir
foreach ip_name $ip_names {
    set ip_dir [file join $ip_repo_dir $ip_name]
    if {[file exists $ip_dir]} {
        file delete -force $ip_dir
    }
}

set package_scripts [list \
    package_axi_gpio_core.tcl \
    package_axi_fnd_core.tcl \
    package_axi_timer_core.tcl \
    package_axi_sensor_core.tcl \
    package_axi_spi_core.tcl \
    package_axi_i2c_core.tcl \
]

set packaged [list]
foreach package_script $package_scripts {
    source [file join $script_dir $package_script]
    lappend packaged $package_script
}

if {[llength [get_projects -quiet]] > 0} {
    close_project
}
create_project custom_ip_catalog_check -in_memory -part xc7a35tcpg236-1 -force
set_property ip_repo_paths $ip_repo_dir [current_project]
update_ip_catalog -rebuild

set missing_defs [list]
foreach ip_name $ip_names {
    set def [get_ipdefs -all "user.org:user:${ip_name}:1.0"]
    if {[llength $def] == 0} {
        lappend missing_defs $ip_name
    }
}
if {[llength $missing_defs] > 0} {
    error "IP catalog update did not expose: $missing_defs"
}
close_project

puts "============================================================"
puts "Custom IP packaging summary"
foreach ip_name $ip_names {
    set component_xml [file join $ip_repo_dir $ip_name component.xml]
    if {![file exists $component_xml]} {
        error "Missing component.xml for $ip_name: $component_xml"
    }
    puts "PACKAGED: $ip_name ($component_xml)"
}
puts "IP catalog update: PASS"
puts "============================================================"
exit 0
