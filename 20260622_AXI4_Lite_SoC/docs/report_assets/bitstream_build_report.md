# Bitstream Build Report

## Run Summary

Prompt 23 built the Basys3 MicroBlaze AXI4-Lite SoC with Vivado 2020.2 through synthesis, implementation, bitstream generation, and hardware platform export.

| Item | Result |
| --- | --- |
| Canonical project root | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` |
| Vivado executable used | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat` |
| Vivado version | 2020.2 |
| Exact command | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/build_microblaze_basys3_bitstream.tcl` |
| Simulation/build ran | Yes, synthesis/implementation/bitstream build ran in batch mode |
| Final result | PASS |
| Final log | `vivado/basys3/microblaze_axi_soc/reports/bitstream_build_20260623_011529_vivado.log` |
| Build summary | `vivado/basys3/microblaze_axi_soc/reports/bitstream_build_summary.txt` |

## Stage Results

| Stage | Result | Evidence |
| --- | --- | --- |
| Open Vivado project | PASS | `microblaze_axi_soc.xpr` opened |
| Confirm BD/IP/XDC | PASS | Required MicroBlaze, AXI UART Lite, six custom IPs, reset inverter, external ports, and XDC were found |
| `validate_bd_design` | PASS | Existing BD validation remained valid |
| Synthesis | PASS | `synth_1` status: `synth_design Complete!`, progress `100%` |
| Synthesis reports | PASS | `synth_utilization.rpt`, `synth_timing_summary.rpt` |
| Implementation | PASS | `impl_1` status after route: `route_design Complete!`, progress `100%` |
| Timing | PASS | WNS `1.772 ns`, TNS `0.000 ns`, WHS `0.023 ns` |
| DRC gate | PASS | 0 errors, 0 critical warnings, 11 warnings |
| Bitstream | PASS | `write_bitstream Complete!`, progress `100%` |
| XSA export | PASS | `write_hw_platform -fixed -include_bit` created the XSA |

## Exported Artifacts

| Artifact | Path | Size |
| --- | --- | --- |
| Bitstream | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit` | 2,192,137 bytes |
| XSA | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa` | 247,260 bytes |

XSA contents include `microblaze_axi_soc.bit`, `microblaze_axi_soc.mmi`, `microblaze_axi_soc_bd.hwh`, SmartConnect HWH metadata, `sysdef.xml`, `xsa.json`, and `xsa.xml`. This confirms the XSA includes the bitstream.

## Implementation Timing

| Metric | Value | Status |
| --- | --- | --- |
| WNS | `1.772 ns` | PASS |
| TNS | `0.000 ns` | PASS |
| WHS | `0.023 ns` | PASS |
| Timing summary message | `All user specified timing constraints are met.` | PASS |

Report path: `vivado/basys3/microblaze_axi_soc/reports/impl_timing_summary.rpt`.

## Implementation Utilization

| Resource | Used | Available | Utilization |
| --- | --- | --- | --- |
| Slice LUTs | 2,926 | 20,800 | 14.07% |
| Slice Registers | 2,491 | 41,600 | 5.99% |
| Block RAM Tile | 32 | 50 | 64.00% |
| DSPs | 3 | 90 | 3.33% |
| Bonded IOB | 62 | 106 | 58.49% |
| BUFGCTRL | 2 | 32 | 6.25% |

Report path: `vivado/basys3/microblaze_axi_soc/reports/impl_utilization.rpt`.

## DRC Summary

Report path: `vivado/basys3/microblaze_axi_soc/reports/impl_drc.rpt`.

| Rule | Severity | Violations | Notes |
| --- | --- | --- | --- |
| CFGBVS-1 | Warning | 1 | Configuration voltage properties not explicitly set |
| DPIP-1 | Warning | 4 | MicroBlaze DSP input pipelining advisories |
| DPOP-1 | Warning | 1 | MicroBlaze DSP PREG output pipelining advisory |
| DPOP-2 | Warning | 1 | MicroBlaze DSP MREG output pipelining advisory |
| RPBF-3 | Warning | 3 | Inout buffering warnings for `dht11_io`, `i2c_scl_io`, `i2c_sda_io` |
| RTSTAT-10 | Warning | 1 | No-routable-load advisory nets inside MDM/SmartConnect |

DRC errors: 0. DRC critical warnings: 0. DRC warnings: 11.

## Build Log Warnings And Errors

Final preserved log scan, anchored at line starts:

| Pattern | Count |
| --- | --- |
| `ERROR:` | 0 |
| `CRITICAL WARNING:` | 37 |
| `WARNING:` | 46 |

The critical warning lines are repeated Timing 38-285 messages for MDM debug generated clocks (`bscan_ext_update` / `bscan_ext_drck`) without valid master clock waveforms. User timing still met WNS/TNS/WHS, and DRC had no critical warnings.

## Fixes Made During Prompt 23

1. `vivado/scripts/build_microblaze_basys3_bitstream.tcl`: removed unsupported `report_timing_summary -force` usage for Vivado 2020.2 and made report generation overwrite-safe by deleting old report files first.
2. `constraints/basys3/basys3_axi_soc.xdc`: changed `reset_i` from CPU_RESETN/C12 to external PMOD JA4/G2 active-low reset because Vivado 2020.2 rejected C12 for part `xc7a35tcpg236-1`.
3. `constraints/basys3/reset_options/reset_external_pmod_ja4_g2.xdc`: added the applied reset fallback snippet.
4. Documentation was updated to record the reset fallback and bitstream/XSA evidence.

## Build Summary File Contents

```text
Vivado executable expected: D:/Xilinx/Vivado/2020.2/bin/vivado.bat
Vivado version: 2020.2
Project root: D:/OndeviceAI2_AXI4_Lite/20260622_AXI4_Lite_SoC
Project: D:/OndeviceAI2_AXI4_Lite/20260622_AXI4_Lite_SoC/vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr
Block design: D:/OndeviceAI2_AXI4_Lite/20260622_AXI4_Lite_SoC/vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.srcs/sources_1/bd/microblaze_axi_soc_bd/microblaze_axi_soc_bd.bd
Wrapper: D:/OndeviceAI2_AXI4_Lite/20260622_AXI4_Lite_SoC/vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.gen/sources_1/bd/microblaze_axi_soc_bd/hdl/microblaze_axi_soc_bd_wrapper.v
XDC: D:/OndeviceAI2_AXI4_Lite/20260622_AXI4_Lite_SoC/constraints/basys3/basys3_axi_soc.xdc
Project open: PASS
Required BD cells: PASS
Required BD external ports: PASS
Basys3 XDC in constrs_1: PASS
validate_bd_design: PASS
Synthesis run status: synth_design Complete!
Implementation run status: route_design Complete!
Timing WNS from get_timing_paths: 1.772
Timing WHS from get_timing_paths: 0.023
DRC ERROR count: 0
DRC CRITICAL WARNING count: 0
DRC WARNING count: 11
Bitstream run status: write_bitstream Complete!
Exported bitstream: D:/OndeviceAI2_AXI4_Lite/20260622_AXI4_Lite_SoC/vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit
Exported XSA: D:/OndeviceAI2_AXI4_Lite/20260622_AXI4_Lite_SoC/vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa
XSA include bit: yes
RESULT: PASS
```

## RTL, Reference, Software, And UVM Status

- No files under `rtl_work/` were intentionally modified.
- No files under `axi_project_unique_sources/` were modified.
- No Vitis workspace was created.
- No user MicroBlaze C software was created.
- No UVM environment was created.
- No board programming was performed.

## Next Step

Proceed to Prompt 24 for the post-bitstream Vitis/BSP/software preparation flow. Do not move to board programming until the software flow and UART command plan are prepared.
