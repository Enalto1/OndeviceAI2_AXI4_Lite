# Package axi_timer_core as a local Vivado IP.
set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir package_common_custom_ip.tcl]

custom_ip_package [dict create \
    name axi_timer_core \
    top axi_timer_core \
    files {
        rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v
        axi_project_unique_sources/sources/stopwatch_datapath.v
        axi_project_unique_sources/sources/watch_datapath.v
        axi_project_unique_sources/sources/watch_fnd_adapter.v
    } \
    sv_files {

    } \
    external_ports {

    } \
]
