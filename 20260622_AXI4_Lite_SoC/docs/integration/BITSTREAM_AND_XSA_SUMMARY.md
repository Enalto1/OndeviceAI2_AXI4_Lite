# Bitstream And XSA Summary

Prompt 23 generated the first passing Basys3 MicroBlaze AXI4-Lite SoC bitstream and exported a fixed hardware platform XSA with the bitstream included.

| Item | Value |
| --- | --- |
| Vivado executable | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat` |
| Vivado version | 2020.2 |
| Build command | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/build_microblaze_basys3_bitstream.tcl` |
| Build result | PASS |
| Timing | WNS `1.772 ns`, TNS `0.000 ns`, WHS `0.023 ns` |
| DRC | 0 errors, 0 critical warnings, 11 warnings |
| Bitstream | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit` |
| XSA | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa` |
| XSA includes bitstream | Yes, `microblaze_axi_soc.bit` is inside the XSA archive |
| Preserved build log | `vivado/basys3/microblaze_axi_soc/reports/bitstream_build_20260623_011529_vivado.log` |

## Important Integration Note

The reset pin changed during Prompt 23. Vivado 2020.2 rejected the previous CPU_RESETN/C12 assignment for the selected part `xc7a35tcpg236-1`, so `reset_i` now uses an external active-low PMOD reset on JA4/G2 with `PULLUP true`. The BD reset topology is unchanged: `reset_i` still passes through `rstn_inv_0` before `proc_sys_reset_0/ext_reset_in`.

## What This XSA Is For

Use this XSA as the hardware input for the next Vitis/BSP/software preparation prompt. It contains the hardware handoff metadata, HWH files, MMI data, and the generated bitstream. No Vitis workspace or user application has been created yet.
