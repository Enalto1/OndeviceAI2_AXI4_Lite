# Offline Board Package Report

## Status

Prompt 25A prepared the offline Basys3 board bring-up package. The board is not currently connected, so hardware programming, JTAG target detection, and UART smoke testing were not attempted.

## Date/Time

2026-06-23 13:09:42 +09:00

## Artifact Check

| Artifact | Path | Exists |
| --- | --- | --- |
| Bitstream | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit` | True |
| XSA | `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa` | True |
| ELF | `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf` | True |

## Files Prepared

Scripts:

- `hw/scripts/program_fpga_and_elf.tcl`
- `hw/scripts/program_fpga_and_elf.bat`
- `hw/scripts/list_hw_targets.tcl`
- `hw/scripts/list_hw_targets.bat`
- `hw/scripts/uart_smoke_test_sequence.txt`

Manual guides:

- `hw/docs/BOARD_CONNECTION_GUIDE.md`
- `hw/docs/RESET_WIRING_GUIDE.md`
- `hw/docs/UART_TERMINAL_GUIDE.md`
- `hw/docs/BOARD_PROGRAMMING_MANUAL_STEPS.md`
- `hw/docs/UART_SMOKE_TEST_SEQUENCE.md`

Package files:

- `hw/package/BOARD_READY_MANIFEST.md`
- `hw/package/checksums_sha256.txt`

## Checksums

SHA256 checksums were generated for the bitstream, XSA, ELF, programming scripts, and UART smoke sequence.

Checksum file:

```text
hw/package/checksums_sha256.txt
```

## Execution Status

| Item | Status |
| --- | --- |
| Hardware target detection | Not run - board unavailable |
| FPGA programming | Not run - board unavailable |
| ELF download | Not run - board unavailable |
| Processor start | Not run - board unavailable |
| UART smoke test | Not run - board unavailable / COM port unavailable |

## Safety Status

- RTL was not modified.
- Reference RTL was not modified.
- Vivado block design was not modified.
- Bitstream was not regenerated or modified.
- XSA was not regenerated or modified.
- ELF was not rebuilt or modified.
- UVM was not created.
- No board success or UART success is claimed.

## Next Manual Steps

When the Basys3 board is available:

1. Connect and power the board.
2. Run `hw/scripts/list_hw_targets.bat`.
3. Run `hw/scripts/program_fpga_and_elf.bat`.
4. Open UART terminal at 9600-8-N-1, no flow control.
5. Execute commands from `hw/scripts/uart_smoke_test_sequence.txt`.
6. Capture UART transcript and LED/FND observations.
