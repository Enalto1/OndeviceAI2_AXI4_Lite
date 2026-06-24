# MicroBlaze Block Design Creation Report

## Run Summary

Prompt 21 created a reproducible Vivado 2020.2 Basys3-targeted MicroBlaze AXI4-Lite block design using the packaged local IP repository.

- Canonical project root: `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC`
- Vivado executable used: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat`
- Vivado version: Vivado v2020.2 (64-bit), SW Build 3064766, IP Build 3064653
- Exact command used from the project root:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/create_microblaze_basys3_bd.tcl
```

- Project path: `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr`
- Block design name: `microblaze_axi_soc_bd`
- FPGA part: `xc7a35tcpg236-1`
- Board part: not available in this Vivado installation; the project was created as a part-only Basys3-compatible project
- Local IP repo path: `vivado/ip_repo`
- Interconnect type: Xilinx SmartConnect, instance `smartconnect_0`
- `validate_bd_design`: PASS
- HDL wrapper: GENERATED, `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.gen/sources_1/bd/microblaze_axi_soc_bd/hdl/microblaze_axi_soc_bd_wrapper.v`
- Final Vivado log copy: `vivado/basys3/microblaze_axi_soc/reports/microblaze_bd_creation_20260622_231359_vivado.log`

## Created Xilinx IP

- `microblaze_0`
- `mdm_0`
- `proc_sys_reset_0`
- `smartconnect_0`
- `axi_uartlite_0`
- `ilmb_v10`
- `dlmb_v10`
- `ilmb_bram_if_cntlr`
- `dlmb_bram_if_cntlr`
- `lmb_bram`
- `xlconstant_reset_locked`

## Created Custom IP

- `axi_gpio_core_0`
- `axi_fnd_core_0`
- `axi_timer_core_0`
- `axi_sensor_core_0`
- `axi_spi_core_0`
- `axi_i2c_core_0`

## Clock And Reset Topology

Clock:

- `clk_100mhz_i` is the external 100 MHz system clock.
- `clk_100mhz_i` drives MicroBlaze, LMB controllers, SmartConnect, AXI UART Lite, all six custom AXI4-Lite peripherals, and `proc_sys_reset_0/slowest_sync_clk`.

Reset:

- `reset_i` is the external active-high reset input.
- `reset_i` connects to `proc_sys_reset_0/ext_reset_in`.
- `xlconstant_reset_locked` drives `proc_sys_reset_0/dcm_locked` high because no clock wizard is used in this step.
- `mdm_0/Debug_SYS_Rst` connects to `proc_sys_reset_0/mb_debug_sys_rst`.
- `proc_sys_reset_0/mb_reset` drives `microblaze_0/Reset`.
- `proc_sys_reset_0/peripheral_reset` drives LMB reset pins.
- `proc_sys_reset_0/peripheral_aresetn` drives SmartConnect, AXI UART Lite, and all six custom `s00_axi_aresetn` pins.

## External Ports

| Port | Direction | Width | Connected IP | Future XDC category |
| --- | --- | --- | --- | --- |
| `clk_100mhz_i` | input | 1 | system clock | Basys3 100 MHz clock |
| `reset_i` | input | 1 | Processor System Reset | Basys3 reset button |
| `uart_rxd_i` | input | 1 | AXI UART Lite RX | USB-UART RX |
| `uart_txd_o` | output | 1 | AXI UART Lite TX | USB-UART TX |
| `led_o` | output | 16 | `axi_gpio_core_0` | LEDs |
| `sw_i` | input | 16 | `axi_gpio_core_0` | Switches |
| `btn_i` | input | 5 | `axi_gpio_core_0` | Buttons |
| `fnd_com_o` | output | 4 | `axi_fnd_core_0` | Seven-segment common/anode |
| `fnd_data_o` | output | 8 | `axi_fnd_core_0` | Seven-segment data |
| `sr04_echo_i` | input | 1 | `axi_sensor_core_0` | PMOD sensor input |
| `sr04_trig_o` | output | 1 | `axi_sensor_core_0` | PMOD sensor output |
| `dht11_io` | inout | 1 | `axi_sensor_core_0` | PMOD bidirectional sensor |
| `spi_sclk_o` | output | 1 | `axi_spi_core_0` | PMOD SPI |
| `spi_mosi_o` | output | 1 | `axi_spi_core_0` | PMOD SPI |
| `spi_miso_i` | input | 1 | `axi_spi_core_0` | PMOD SPI |
| `spi_ss_n_o` | output | 1 | `axi_spi_core_0` | PMOD SPI |
| `i2c_scl_io` | inout | 1 | `axi_i2c_core_0` | PMOD I2C with pull-up |
| `i2c_sda_io` | inout | 1 | `axi_i2c_core_0` | PMOD I2C with pull-up |

## Address Map

| Peripheral/IP | Expected base | Actual base | Range | Expected high | Actual high | Status |
| --- | --- | --- | --- | --- | --- | --- |
| AXI UART Lite | `0x4060_0000` | `0x4060_0000` | 64 KB | `0x4060_FFFF` | `0x4060_FFFF` | PASS |
| `axi_gpio_core` | `0x44A0_0000` | `0x44A0_0000` | 64 KB | `0x44A0_FFFF` | `0x44A0_FFFF` | PASS |
| `axi_fnd_core` | `0x44A1_0000` | `0x44A1_0000` | 64 KB | `0x44A1_FFFF` | `0x44A1_FFFF` | PASS |
| `axi_timer_core` | `0x44A2_0000` | `0x44A2_0000` | 64 KB | `0x44A2_FFFF` | `0x44A2_FFFF` | PASS |
| `axi_sensor_core` | `0x44A3_0000` | `0x44A3_0000` | 64 KB | `0x44A3_FFFF` | `0x44A3_FFFF` | PASS |
| `axi_spi_core` | `0x44A4_0000` | `0x44A4_0000` | 64 KB | `0x44A4_FFFF` | `0x44A4_FFFF` | PASS |
| `axi_i2c_core` | `0x44A5_0000` | `0x44A5_0000` | 64 KB | `0x44A5_FFFF` | `0x44A5_FFFF` | PASS |

Local MicroBlaze LMB memory was mapped at `0x0000_0000` with a 128 KB range in both instruction and data spaces.

## Warnings And Errors

Final log scan:

- `ERROR:` lines: none
- `CRITICAL WARNING:` lines: none
- `WARNING:` lines: two

The two warnings are `BD 41-1306` messages for manually exposing AXI UART Lite `rx` and `tx` pins as individual top-level ports `uart_rxd_i` and `uart_txd_o`. This is intentional for the future Basys3 XDC naming plan.

During debugging, Vivado reported duplicate custom-IP clock association critical warnings. Root cause was generated packaged IP metadata value `s00_axi:S00_AXI`. The Prompt 21 Tcl now normalizes the generated `component.xml` metadata to `S00_AXI` before importing the local IP repository. This changed generated IP metadata only, not RTL source.

## Skipped Work

- Synthesis: skipped
- Implementation: skipped
- Bitstream generation: skipped
- Hardware export/XSA: skipped
- Vitis workspace: not created
- MicroBlaze C software: not created
- UVM: not created
- Exact XDC pin assignments: not created

## Files Created

- `vivado/scripts/create_microblaze_basys3_bd.tcl`
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr`
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.srcs/sources_1/bd/microblaze_axi_soc_bd/microblaze_axi_soc_bd.bd`
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.gen/sources_1/bd/microblaze_axi_soc_bd/hdl/microblaze_axi_soc_bd_wrapper.v`
- `vivado/basys3/microblaze_axi_soc/reports/bd_address_map_actual.tsv`
- `vivado/basys3/microblaze_axi_soc/reports/bd_address_report.txt`
- `vivado/basys3/microblaze_axi_soc/reports/bd_cells.txt`
- `vivado/basys3/microblaze_axi_soc/reports/bd_external_ports.tsv`
- `vivado/basys3/microblaze_axi_soc/reports/bd_validation_summary.txt`
- `vivado/basys3/microblaze_axi_soc/reports/microblaze_bd_creation_20260622_231359_vivado.log`
- `docs/report_assets/microblaze_bd_creation_report.md`
- `docs/integration/MICROBLAZE_BD_SUMMARY.md`
- `docs/integration/BD_EXTERNAL_PORT_SUMMARY.md`
- `docs/integration/BD_ADDRESS_MAP_VERIFICATION.md`
- `docs/integration/BD_NEXT_STEPS.md`

## Files Modified

- `vivado/ip_repo/*/component.xml` metadata: `ASSOCIATED_BUSIF` normalized from `s00_axi:S00_AXI` to `S00_AXI`
- Documentation updates listed in Prompt 21 traceability

## RTL And Reference Status

- No files under `rtl_work/` were modified.
- No files under `axi_project_unique_sources/` were modified.
- Packaged HDL source copies under `vivado/ip_repo/*/src/` were not modified.

## Next Step

Prompt 22: Basys3 XDC pin mapping and constraints preparation.

