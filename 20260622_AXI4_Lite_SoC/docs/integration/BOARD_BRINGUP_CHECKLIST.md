# Board Bring-Up Checklist

## Current Prompt 25A Status

The offline board bring-up package is prepared. The Basys3 board is not connected during Prompt 25A, so hardware target detection, FPGA programming, ELF download, processor start, and UART smoke testing were not run.

## Required Inputs

| Item | Path | Status |
| --- | --- | --- |
| Bitstream | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit` | exists |
| XSA | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa` | exists |
| ELF | `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf` | exists |
| Board package manifest | `hw/package/BOARD_READY_MANIFEST.md` | exists |
| Checksums | `hw/package/checksums_sha256.txt` | exists |

## Physical Setup

- Connect the Basys3 USB cable.
- Turn board power ON.
- Set JP1 for USB power if using USB power.
- JTAG and UART use the same USB cable.
- Install Digilent/Xilinx cable drivers if no hardware target is detected.

## Reset Reminder

Reset is mapped to PMOD JA4/G2 and is active-low.

```text
PMOD JA4 signal ---- push button ---- GND
```

- Released: logic 1, reset released.
- Pressed: logic 0, reset active.
- Do not hold reset low during UART testing.
- Onboard buttons remain GPIO `btn_i[4:0]`.

## UART Settings

| Setting | Value |
| --- | --- |
| Baud | 9600 |
| Data bits | 8 |
| Parity | none |
| Stop bits | 1 |
| Flow control | none |

## Manual Bring-up Steps When Board Is Available

1. Run `hw/scripts/list_hw_targets.bat`.
2. Run `hw/scripts/program_fpga_and_elf.bat`.
3. Open a UART terminal using the settings above.
4. Run commands from `hw/scripts/uart_smoke_test_sequence.txt`.
5. Capture UART transcript and LED/FND observations.

## Stop Conditions

- No hardware target appears.
- FPGA programming fails.
- ELF download fails.
- No UART banner or response appears.
- Version registers do not return expected values.
- Reset behavior does not match active-low PMOD JA4/G2 reset.

Do not claim board demo success until UART responses are actually observed.
