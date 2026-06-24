# Package axi_sensor_core as a local Vivado IP.
set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir package_common_custom_ip.tcl]

custom_ip_package [dict create \
    name axi_sensor_core \
    top axi_sensor_core \
    files {
        rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v
        axi_project_unique_sources/sources/sr04.v
        axi_project_unique_sources/sources/dht11.v
    } \
    sv_files {

    } \
    external_ports {
        sr04_echo_i
        sr04_trig_o
        dht11_io
    } \
]
