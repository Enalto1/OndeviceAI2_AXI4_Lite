# Board Programming Manual Steps

## Preconditions

- Basys3 board is connected and powered.
- Vitis/XSCT 2020.2 exists at `D:\Xilinx\Vitis\2020.2\bin\xsct.bat`.
- Bitstream exists at `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit`.
- ELF exists at `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf`.
- Reset is not held low.

## Manual Steps

1. Connect the Basys3 board by USB.
2. Power on the board.
3. From the project root, run:

   ```bat
   hw\scripts\list_hw_targets.bat
   ```

4. Confirm an Artix-7/xc7a35t FPGA target and MicroBlaze target are visible.
5. From the project root, run:

   ```bat
   hw\scripts\program_fpga_and_elf.bat
   ```

6. Open a UART terminal with 9600-8-N-1 and no flow control.
7. If needed, press and release the external active-low reset on PMOD JA4/G2.
8. Run commands from:

   ```text
   hw/scripts/uart_smoke_test_sequence.txt
   ```

9. Capture the UART transcript and any visible LED/FND behavior.

## Stop Conditions

- No hardware target appears in `list_hw_targets.bat`.
- FPGA programming fails.
- ELF download fails.
- The processor does not start.
- No UART banner or response appears.
- Version registers do not return expected values.

Do not modify RTL until the failure is isolated.
