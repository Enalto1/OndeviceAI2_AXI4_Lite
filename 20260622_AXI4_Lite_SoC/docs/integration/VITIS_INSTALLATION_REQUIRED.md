# Vitis Installation Status

## Current Result

The previous Vitis installation blocker is resolved for this project. XSCT/Vitis 2020.2 was found at:

```text
D:\Xilinx\Vitis\2020.2\bin\xsct.bat
```

The MicroBlaze standalone UART command software build passed and generated:

```text
D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC\sw\vitis_workspace\axi_soc_uart_app\Debug\axi_soc_uart_app.elf
```

## Historical Note

Prompt 24.5 previously found only 2024.2 XSCT paths and did not use them. After installing Vitis 2020.2, the project build wrapper selected the correct 2020.2 path.

## Next Step

Proceed to Prompt 25: board programming and UART smoke test. Do not claim board success until the hardware run is observed and recorded.
