# Vitis Workspace Summary

## Current Status

Vitis/XSCT 2020.2 was found at `D:\Xilinx\Vitis\2020.2\bin\xsct.bat`, and the MicroBlaze standalone UART command application build passed.

## Generated Workspace Objects

| Object | Path | Status |
| --- | --- | --- |
| Workspace | `sw/vitis_workspace` | generated |
| Platform | `sw/vitis_workspace/microblaze_axi_soc_platform` | generated from Prompt 23 XSA |
| Domain | `standalone_domain` | generated |
| Application | `sw/vitis_workspace/axi_soc_uart_app` | generated |
| ELF | `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf` | generated |

## Inputs

| Item | Path | Status |
| --- | --- | --- |
| XSA | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa` | exists |
| Bitstream | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit` | exists |
| Software source | `sw/src` | copied into app project |

## Build Command

```bat
cmd /c "D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC\sw\scripts\create_and_build_software.bat"
```

## Result

Build passed. ELF generated:

```text
D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC\sw\vitis_workspace\axi_soc_uart_app\Debug\axi_soc_uart_app.elf
```

## Next Step

Proceed to Prompt 25: board programming and UART smoke test. This summary does not claim any board-level success yet.
