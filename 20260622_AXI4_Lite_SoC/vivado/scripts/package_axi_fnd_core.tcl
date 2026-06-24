# Package axi_fnd_core as a local Vivado IP.
set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir package_common_custom_ip.tcl]

custom_ip_package [dict create \
    name axi_fnd_core \
    top axi_fnd_core \
    files {
        rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v
        axi_project_unique_sources/sources/fnd_controller.v
    } \
    sv_files {

    } \
    external_ports {
        fnd_com_o
        fnd_data_o
    } \
]
