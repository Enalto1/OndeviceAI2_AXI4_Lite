# Custom IP Packaging Report

## Run Summary

Prompt 20 packaged the six custom AXI4-Lite peripherals as local Vivado IP under the canonical project root.

- Canonical project root: `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC`
- Vivado executable used: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat`
- Vivado version: Vivado v2020.2 (64-bit), SW Build 3064766, IP Build 3064653
- Exact command used from the project root:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/package_all_custom_ip.tcl
```

- Packaging was run: Yes
- Packaging result: PASS
- Local IP catalog refresh: PASS
- Vivado log copied to: `vivado/ip_repo/package_all_custom_ip_20260622_225119_vivado.log`
- Vivado also wrote the default root log and journal: `vivado.log`, `vivado.jou`

## Packaged IP List

- `axi_gpio_core`
- `axi_fnd_core`
- `axi_timer_core`
- `axi_sensor_core`
- `axi_spi_core`
- `axi_i2c_core`

Each packaged IP uses:

- Vendor: `user.org`
- Library: `user`
- Version: `1.0`
- Taxonomy: `/UserIP`
- AXI4-Lite slave interface name: `S00_AXI`
- Clock: `s00_axi_aclk`
- Active-low reset: `s00_axi_aresetn`

## Source Files Included

`axi_gpio_core`:

- `rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v`
- `rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v`

`axi_fnd_core`:

- `rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v`
- `axi_project_unique_sources/sources/fnd_controller.v`

`axi_timer_core`:

- `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v`
- `axi_project_unique_sources/sources/stopwatch_datapath.v`
- `axi_project_unique_sources/sources/watch_datapath.v`
- `axi_project_unique_sources/sources/watch_fnd_adapter.v`

`axi_sensor_core`:

- `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v`
- `axi_project_unique_sources/sources/sr04.v`
- `axi_project_unique_sources/sources/dht11.v`

`axi_spi_core`:

- `rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v`
- `axi_project_unique_sources/sources/spi_master_byte.sv`

`axi_i2c_core`:

- `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v`
- `axi_project_unique_sources/sources/i2c_master_core.sv`

## External Ports Confirmed

`axi_gpio_core`:

- `led_o`
- `sw_i`
- `btn_i`

`axi_fnd_core`:

- `fnd_com_o`
- `fnd_data_o`

`axi_timer_core`:

- No external non-AXI ports

`axi_sensor_core`:

- `sr04_echo_i`
- `sr04_trig_o`
- `dht11_io`

`axi_spi_core`:

- `spi_sclk_o`
- `spi_mosi_o`
- `spi_miso_i`
- `spi_ss_n_o`

`axi_i2c_core`:

- `i2c_scl_io`
- `i2c_sda_io`

## Validation Results

- `component.xml` exists for all six packaged IP folders.
- `get_ipdefs -all user.org:user:<ip_name>:1.0` found all six packaged IP definitions after `update_ip_catalog -rebuild`.
- `S00_AXI` is present for all six packaged IPs.
- `s00_axi_aclk` is associated with `S00_AXI` through `ASSOCIATED_BUSIF` and `ASSOCIATED_RESET` metadata.
- `s00_axi_aresetn` is marked active low through reset `POLARITY` metadata.
- All expected external wrapper ports are present in the generated component metadata.
- `ipx::check_integrity` passed for each packaged IP.

## Mixed-Language Handling

SPI and I2C include SystemVerilog dependency files:

- `spi_master_byte.sv`
- `i2c_master_core.sv`

The packaging Tcl sets these files to `SystemVerilog`. The generated component metadata includes `systemVerilogSource` entries for both `.sv` files. Vivado 2020.2 emitted informational `IP_Flow 19-5654` messages because each top wrapper is Verilog while the dependency is SystemVerilog. These are informational messages, not warnings or errors.

## Warnings And Errors

Actual log scan result:

- `ERROR:` lines: none
- `CRITICAL WARNING:` lines: none
- Actual `WARNING:` lines: none

Informational notes observed:

- `IP_Flow 19-5654` for SPI and I2C mixed Verilog/SystemVerilog packaging.
- `IP_Flow 19-2187` noting that Product Guide files are missing.
- `IP_Flow 19-2181` noting that Payment Required metadata is not set.

These informational notes are acceptable for local project IP packaging.

## Fixes Made

Tcl and metadata fixes were made before the final passing run:

- Created a shared helper script, `vivado/scripts/package_common_custom_ip.tcl`, to keep the six package scripts consistent.
- Corrected the individual package scripts to use robust Tcl list syntax for source file and port lists.
- Removed invalid manual clock/reset property writes that caused `Unknown property PARAMETER.ASSOCIATED_BUSIF` and `Unknown property PARAMETER.ASSOCIATED_RESET` messages during an earlier packaging attempt.
- Used `ipx::associate_bus_interfaces -busif S00_AXI -clock s00_axi_aclk` for clock/reset association.
- Used `ipx::package_project -force_update_compile_order` to let Vivado update compile order during packaging.

## RTL And Reference Status

- Project RTL wrappers were not modified for Prompt 20.
- Reference RTL under `axi_project_unique_sources/` was not modified.
- Adapted GPIO debounce RTL was not modified.
- No MicroBlaze block design was created.
- No bitstream was created.
- No Vitis workspace or C software was created.
- No UVM environment was created.

## Generated Packaging Outputs

- `vivado/scripts/package_common_custom_ip.tcl`
- `vivado/scripts/package_axi_gpio_core.tcl`
- `vivado/scripts/package_axi_fnd_core.tcl`
- `vivado/scripts/package_axi_timer_core.tcl`
- `vivado/scripts/package_axi_sensor_core.tcl`
- `vivado/scripts/package_axi_spi_core.tcl`
- `vivado/scripts/package_axi_i2c_core.tcl`
- `vivado/scripts/package_all_custom_ip.tcl`
- `vivado/ip_repo/axi_gpio_core/component.xml`
- `vivado/ip_repo/axi_fnd_core/component.xml`
- `vivado/ip_repo/axi_timer_core/component.xml`
- `vivado/ip_repo/axi_sensor_core/component.xml`
- `vivado/ip_repo/axi_spi_core/component.xml`
- `vivado/ip_repo/axi_i2c_core/component.xml`
- `vivado/ip_repo/package_all_custom_ip_20260622_225119_vivado.log`

## Next Step

Prompt 21: Create MicroBlaze Basys3 block design using packaged local IP.
