# Custom IP Packaging Plan

## Scope

This document prepares local Vivado IP packaging. Prompt 19 does not package IP or create packaged IP directories.

## Packaging Table

| IP | Wrapper file | Required dependency files | HDL language types | External ports | AXI interface name | Vivado IP packager notes |
| --- | --- | --- | --- | --- | --- | --- |
| `axi_gpio_core` | `rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v` | `rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v` | Verilog | `led_o[15:0]`, `sw_i[15:0]`, `btn_i[4:0]` | `S00_AXI` from `s00_axi_*` ports | Package wrapper and adapted debounce helper together. Reference GPIO files remain read-only. |
| `axi_fnd_core` | `rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v` | `axi_project_unique_sources/sources/fnd_controller.v` | Verilog | `fnd_com_o[3:0]`, `fnd_data_o[7:0]` | `S00_AXI` from `s00_axi_*` ports | Include reused controller source and preserve display output polarity/gating. |
| `axi_timer_core` | `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v` | `axi_project_unique_sources/sources/stopwatch_datapath.v`, `axi_project_unique_sources/sources/watch_datapath.v`, `axi_project_unique_sources/sources/watch_fnd_adapter.v` | Verilog | None | `S00_AXI` from `s00_axi_*` ports | No external non-AXI ports. Timer-to-FND transfer is software responsibility. |
| `axi_sensor_core` | `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v` | `axi_project_unique_sources/sources/sr04.v`, `axi_project_unique_sources/sources/dht11.v` | Verilog | `sr04_echo_i`, `sr04_trig_o`, `dht11_io` | `S00_AXI` from `s00_axi_*` ports | Mark `dht11_io` as external inout and verify tri-state handling during packaging. |
| `axi_spi_core` | `rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v` | `axi_project_unique_sources/sources/spi_master_byte.sv` | Verilog wrapper plus SystemVerilog dependency | `spi_sclk_o`, `spi_mosi_o`, `spi_miso_i`, `spi_ss_n_o` | `S00_AXI` from `s00_axi_*` ports | Ensure Vivado treats `spi_master_byte.sv` as SystemVerilog in packaged IP. |
| `axi_i2c_core` | `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v` | `axi_project_unique_sources/sources/i2c_master_core.sv` | Verilog wrapper plus SystemVerilog dependency | `i2c_scl_io`, `i2c_sda_io` | `S00_AXI` from `s00_axi_*` ports | Ensure Vivado treats `i2c_master_core.sv` as SystemVerilog and marks SCL/SDA as external inout ports. |

## General Packager Notes

- Keep packaged IP source lists minimal and peripheral-local.
- Do not include testbenches, simulation reports, UVM files, or unrelated reference RTL in packaged IP.
- Preserve the documented 32-bit AXI4-Lite register behavior and reset polarity.
- After packaging, instantiate packaged IP in a new block design and verify the address map before software export.
- Mixed Verilog/SystemVerilog packaging applies to SPI and I2C.

## Prompt 20 Packaging Result

Prompt 20 completed local Vivado 2020.2 IP packaging for all six custom AXI4-Lite peripherals.

- Command used: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/package_all_custom_ip.tcl`
- Local IP repository: `vivado/ip_repo`
- Result: PASS
- IP catalog refresh: PASS
- Evidence report: `docs/report_assets/custom_ip_packaging_report.md`
- Final Vivado log copy: `vivado/ip_repo/package_all_custom_ip_20260622_225119_vivado.log`

Packaged local IP folders:

- `vivado/ip_repo/axi_gpio_core`
- `vivado/ip_repo/axi_fnd_core`
- `vivado/ip_repo/axi_timer_core`
- `vivado/ip_repo/axi_sensor_core`
- `vivado/ip_repo/axi_spi_core`
- `vivado/ip_repo/axi_i2c_core`

All packages expose `S00_AXI`, `s00_axi_aclk`, and active-low `s00_axi_aresetn`. SPI and I2C `.sv` dependencies are included as SystemVerilog source entries. No RTL wrappers or reference RTL files were modified. MicroBlaze block design, software, bitstream, and UVM work remain not started in this step.
