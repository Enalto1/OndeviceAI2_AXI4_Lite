# Package axi_spi_core as a local Vivado IP.
set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir package_common_custom_ip.tcl]

custom_ip_package [dict create \
    name axi_spi_core \
    top axi_spi_core \
    files {
        rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v
        axi_project_unique_sources/sources/spi_master_byte.sv
    } \
    sv_files {
        axi_project_unique_sources/sources/spi_master_byte.sv
    } \
    external_ports {
        spi_sclk_o
        spi_mosi_o
        spi_miso_i
        spi_ss_n_o
    } \
]
