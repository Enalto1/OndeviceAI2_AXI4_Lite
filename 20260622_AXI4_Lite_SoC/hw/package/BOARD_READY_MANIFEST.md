# Board Ready Manifest

## Prompt 25A Status

This offline board bring-up package is prepared for later Basys3 programming. The board is not connected during Prompt 25A, so no programming, target detection, or UART smoke test was attempted.

## Required Build Artifacts

| Artifact | Path | Exists |
| --- | --- | --- |
| Bitstream | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit` | True |
| XSA | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa` | True |
| ELF | `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf` | True |

## Programming Scripts

| Script | Purpose |
| --- | --- |
| `hw/scripts/list_hw_targets.bat` | Runs XSCT target listing only. |
| `hw/scripts/list_hw_targets.tcl` | Connects to hw_server and lists targets. |
| `hw/scripts/program_fpga_and_elf.bat` | Runs the programming/download XSCT Tcl script. |
| `hw/scripts/program_fpga_and_elf.tcl` | Programs FPGA, downloads ELF, starts MicroBlaze when board is connected. |

## UART Smoke Test

| File | Purpose |
| --- | --- |
| `hw/scripts/uart_smoke_test_sequence.txt` | Manual command sequence. |
| `hw/docs/UART_SMOKE_TEST_SEQUENCE.md` | Expected results and evidence checklist. |
| `hw/docs/UART_TERMINAL_GUIDE.md` | COM port and terminal settings. |

## Board Guides

| File | Purpose |
| --- | --- |
| `hw/docs/BOARD_CONNECTION_GUIDE.md` | Board power, USB, JTAG/UART, and sensor cautions. |
| `hw/docs/RESET_WIRING_GUIDE.md` | PMOD JA4/G2 active-low reset wiring. |
| `hw/docs/BOARD_PROGRAMMING_MANUAL_STEPS.md` | Manual bring-up sequence. |

## Known Board Requirements

- Basys3 USB cable connected for JTAG and UART.
- Power switch ON.
- JP1 set for USB power if powering from USB.
- Vitis/XSCT 2020.2 available at `D:\Xilinx\Vitis\2020.2\bin\xsct.bat`.
- PMOD JA4/G2 reset is active-low and should not be held low during normal operation.
- UART terminal uses 9600 baud, 8 data bits, no parity, 1 stop bit, no flow control.
- Do not connect 5V sensor outputs directly to FPGA pins.

## Checksums

SHA256 checksums are stored in:

```text
hw/package/checksums_sha256.txt
```

## Next Manual Step

When the board is available, run:

```bat
hw\scripts\list_hw_targets.bat
hw\scripts\program_fpga_and_elf.bat
```

Then perform the UART smoke test using:

```text
hw/scripts/uart_smoke_test_sequence.txt
```
