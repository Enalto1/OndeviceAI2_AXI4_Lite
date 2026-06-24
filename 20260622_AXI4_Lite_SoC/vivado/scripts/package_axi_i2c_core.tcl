# Package axi_i2c_core as a local Vivado IP.
set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir package_common_custom_ip.tcl]

custom_ip_package [dict create \
    name axi_i2c_core \
    top axi_i2c_core \
    files {
        rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v
        axi_project_unique_sources/sources/i2c_master_core.sv
    } \
    sv_files {
        axi_project_unique_sources/sources/i2c_master_core.sv
    } \
    external_ports {
        i2c_scl_io
        i2c_sda_io
    } \
]
