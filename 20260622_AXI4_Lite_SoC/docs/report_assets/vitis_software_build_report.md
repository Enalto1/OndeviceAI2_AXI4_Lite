# Vitis Software Build Report

## Current Summary

Vitis/XSCT 2020.2 was found and the MicroBlaze standalone UART command software build passed.

## Project Paths

| Item | Path | Status |
| --- | --- | --- |
| Project root | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` | canonical workspace |
| XSA | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa` | exists |
| Bitstream | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit` | exists |
| Software source | `sw/src` | exists; static check PASS |
| Vitis workspace | `sw/vitis_workspace` | generated |
| Platform | `sw/vitis_workspace/microblaze_axi_soc_platform` | generated |
| Application | `sw/vitis_workspace/axi_soc_uart_app` | generated |
| ELF | `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf` | generated |

## XSCT Selection

| Candidate | Exists | Selected |
| --- | --- | --- |
| `D:\Xilinx\Vitis\2020.2\bin\xsct.bat` | yes | yes |
| `C:\Xilinx\Vitis\2020.2\bin\xsct.bat` | no | no |
| `D:\Xilinx\SDK\2020.2\bin\xsct.bat` | no | no |
| `C:\Xilinx\SDK\2020.2\bin\xsct.bat` | no | no |
| `D:\Xilinx\Vivado\2020.2\bin\xsct.bat` | no | no |
| `C:\Xilinx\Vivado\2020.2\bin\xsct.bat` | no | no |

Other installed XSCT paths were observed under 2024.2, but they were not selected.

## Command Run

```bat
cmd /c "D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC\sw\scripts\create_and_build_software.bat"
```

The wrapper selected:

```text
D:\Xilinx\Vitis\2020.2\bin\xsct.bat
```

## Build Result

| Item | Result |
| --- | --- |
| Build ran | yes |
| Build result | PASS |
| Workspace created | yes |
| Platform created from XSA | yes |
| Standalone BSP built | yes |
| Application created | yes |
| ELF generated | yes |

ELF:

```text
D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC\sw\vitis_workspace\axi_soc_uart_app\Debug\axi_soc_uart_app.elf
```

ELF file size: 222,032 bytes.

ELF section summary:

```text
text    data    bss     dec     hex
32152   1308    3172    36632   8f18
```

## Warnings And Notes

Observed during build:

- Vitis/XSCT emitted deprecated `sysconfig` command warnings while generating platform/domain objects.
- BSP build emitted a `microblaze_sleep.c` pragma note about sleep routines using assembly instructions.
- No build-stopping errors were observed.

Generated log files include:

- `sw/vitis_workspace/IDE.log`
- `sw/vitis_workspace/microblaze_axi_soc_platform/logs/platform.log`
- `sw/vitis_workspace/.metadata/.log`

## Static Software Check

Static source check result: PASS.

Detailed report:

```text
docs/report_assets/software_static_check_report.md
```

## Files And Hardware Safety

- RTL unchanged.
- Reference RTL unchanged.
- Vivado block design unchanged.
- Bitstream unchanged.
- XSA unchanged.
- UVM not created.
- FPGA programming skipped.
- Hardware Manager not launched.
- No board success claimed.

## Next Step

Proceed to Prompt 25: board programming and UART smoke test using the generated bitstream and ELF.
