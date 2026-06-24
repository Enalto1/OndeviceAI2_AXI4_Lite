# Package axi_gpio_core as a local Vivado IP.
set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir package_common_custom_ip.tcl]

custom_ip_package [dict create \
    name axi_gpio_core \
    top axi_gpio_core \
    files {
        rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v
        rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v
    } \
    sv_files {

    } \
    external_ports {
        led_o
        sw_i
        btn_i
    } \
]
