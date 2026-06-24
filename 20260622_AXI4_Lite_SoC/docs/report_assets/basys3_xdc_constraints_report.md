# Basys3 XDC Constraints Report

## Run Summary

Prompt 22 v1 created and applied a first-pass Basys3 XDC for the Prompt 21 MicroBlaze AXI4-Lite SoC block design. The pin map is usable now, while reset and PMOD assignments remain easy to revise later.

- Canonical project root: `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC`
- Vivado executable used: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat`
- Vivado version: 2020.2
- Exact command:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/apply_basys3_xdc.tcl
```

- Project path: `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr`
- XDC path: `constraints/basys3/basys3_axi_soc.xdc`
- Reset option snippets: `constraints/basys3/reset_options/`
- XDC project fileset: `constrs_1`
- Block design: `microblaze_axi_soc_bd`
- Final v1 log: `vivado/basys3/microblaze_axi_soc/reports/basys3_xdc_apply_v1_20260623_002733_vivado.log`

## Validation Result

- XDC exists: PASS
- XDC added to project: PASS
- `validate_bd_design`: PASS
- All constrained ports exist in `microblaze_axi_soc_bd_wrapper.v`: PASS
- Duplicate `PACKAGE_PIN` assignment check: PASS
- Clock constraint exists for `clk_100mhz_i`: PASS
- Reset policy documented and revisable: PASS
- Final log `ERROR:` lines: none
- Final log `CRITICAL WARNING:` lines: none
- Final log `WARNING:` lines: none

A verified Basys3 master XDC was not found in the canonical project root. The pin list follows the Prompt 22 v1 assignment table and the actual wrapper port names.

## Clock And Reset

| Function | Logical signal | Board signal | PACKAGE_PIN | Policy |
| --- | --- | --- | --- | --- |
| Clock | `clk_100mhz_i` | 100 MHz oscillator | W5 | `create_clock -period 10.000` |
| Reset | `reset_i` | PMOD JA4 external reset | G2 | Current active-low fallback, PULLUP true, inverted by `rstn_inv_0` before `proc_sys_reset_0/ext_reset_in`; CPU_RESETN/C12 rejected by Vivado in Prompt 23 |

`proc_sys_reset_0/CONFIG.C_EXT_RESET_HIGH` is read-only in the opened Vivado 2020.2 BD, so Prompt 22 v1 uses `rstn_inv_0`, a `util_vector_logic` NOT block. The HDL wrapper was regenerated when this BD reset adapter was added; top-level ports did not change.

## Reset Revision Options

- Option A: current applied fallback is external PMOD JA4/G2 active-low reset; this keeps all GPIO buttons available.
- Option B: move reset to another external PMOD active-low button using `constraints/basys3/reset_options/reset_external_pmod_template.xdc`.
- Option C: use a normal onboard button as reset only if the GPIO button map is intentionally reduced or remapped.

Detailed instructions are in `docs/integration/BASYS3_RESET_REVISION_GUIDE.md`.

## UART Mapping

| Logical signal | Board signal | PACKAGE_PIN | IOSTANDARD |
| --- | --- | --- | --- |
| `uart_rxd_i` | USB-UART RX | B18 | LVCMOS33 |
| `uart_txd_o` | USB-UART TX | A18 | LVCMOS33 |

## GPIO And FND Mapping

- Switches: `sw_i[15:0]` mapped to Basys3 SW15..SW0.
- LEDs: `led_o[15:0]` mapped to Basys3 LD15..LD0.
- Buttons: `btn_i[4:0]` mapped to btnD/btnR/btnL/btnU/btnC and preserved for GPIO.
- FND: `fnd_data_o[7:0]` maps to CA..CG/DP, and `fnd_com_o[3:0]` maps to AN0..AN3.

## PMOD Mapping

| Peripheral | PMOD | Signals | Status |
| --- | --- | --- | --- |
| Sensor | JA | `sr04_trig_o`, `sr04_echo_i`, `dht11_io` | Provisional v1 mapping |
| SPI | JB | `spi_sclk_o`, `spi_mosi_o`, `spi_miso_i`, `spi_ss_n_o` | Provisional v1 mapping |
| I2C | JC | `i2c_scl_io`, `i2c_sda_io` | Provisional v1 mapping |

`dht11_io`, `i2c_scl_io`, and `i2c_sda_io` are inout ports. Weak internal pull-ups are enabled in XDC for these ports, but external pull-ups remain recommended for DHT11 and required/recommended for I2C board use.

## Files Created

- `constraints/basys3/basys3_axi_soc.xdc`
- `constraints/basys3/reset_options/README.md`
- `constraints/basys3/reset_options/reset_cpu_resetn_c12.xdc`
- `constraints/basys3/reset_options/reset_external_pmod_template.xdc`
- `vivado/scripts/apply_basys3_xdc.tcl`
- `docs/integration/BASYS3_XDC_PIN_MAP.md`
- `docs/integration/BASYS3_RESET_POLICY.md`
- `docs/integration/BASYS3_RESET_REVISION_GUIDE.md`
- `docs/report_assets/basys3_xdc_constraints_report.md`
- `vivado/basys3/microblaze_axi_soc/reports/basys3_xdc_apply_summary.txt`
- `vivado/basys3/microblaze_axi_soc/reports/basys3_reset_policy_actual.txt`
- `vivado/basys3/microblaze_axi_soc/reports/basys3_xdc_port_check.tsv`
- `vivado/basys3/microblaze_axi_soc/reports/basys3_xdc_pin_check.tsv`
- `vivado/basys3/microblaze_axi_soc/reports/basys3_xdc_apply_v1_20260623_002733_vivado.log`

## Files Modified

- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr`: XDC is present in `constrs_1`.
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.srcs/sources_1/bd/microblaze_axi_soc_bd/microblaze_axi_soc_bd.bd`: contains `rstn_inv_0` for active-low external reset handling.
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.gen/sources_1/bd/microblaze_axi_soc_bd/hdl/microblaze_axi_soc_bd_wrapper.v`: regenerated when the reset adapter was first added; same top-level ports.
- Prompt 22 v1 documentation and traceability files.

## Skipped Work

- Synthesis: skipped
- Implementation: skipped
- Bitstream generation: skipped
- XSA export: skipped
- Vitis workspace: not created
- User MicroBlaze C application: not created
- UVM: not created
- Board demo: not claimed or started

Vivado may retain normal IP output products generated by the block design, including Xilinx IP simulation/model artifacts and the MicroBlaze bootloop output product. No Vitis workspace or user application was created.

## RTL And Reference Status

- No files under `rtl_work/` were modified.
- No files under `axi_project_unique_sources/` were modified.
- No reference RTL files were modified.

## Next Step

Prompt 23: Synthesis, implementation, bitstream generation, and hardware export preparation.

## Prompt 23 Reset Pin Addendum

During the Prompt 23 bitstream build, Vivado 2020.2 rejected the previous C12 reset pin assignment for part `xc7a35tcpg236-1`:

```text
'C12' is not a valid site or package pin name.
```

The XDC reset section was therefore revised to external PMOD JA4/G2 active-low reset with `PULLUP true`. The BD reset topology remains unchanged: `reset_i` is inverted by `rstn_inv_0` before `proc_sys_reset_0/ext_reset_in`. All five normal Basys3 buttons remain mapped to GPIO.

