# Post-Bitstream Next Steps

Prompt 23 completed the passing bitstream/XSA handoff. The MicroBlaze standalone UART command software builds successfully with Vitis/XSCT 2020.2. Prompt 25A prepared the offline board bring-up package, but the board is not connected yet.

## Current Status

| Item | Status |
| --- | --- |
| Bitstream | exists: `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit` |
| XSA | exists: `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa` |
| ELF | exists: `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf` |
| Offline board package | prepared under `hw/` |
| Board programming | not run - board unavailable |
| UART smoke test | not run - board unavailable / COM port unavailable |

## Next Recommended Step

When the Basys3 board is available:

```bat
hw\scripts\list_hw_targets.bat
hw\scripts\program_fpga_and_elf.bat
```

Then perform the UART smoke test using:

```text
hw/scripts/uart_smoke_test_sequence.txt
```

## Carry-Forward Checks

- Use Vivado/Vitis 2020.2-compatible flows.
- Keep UVM deferred until explicitly requested.
- Do not modify reference RTL.
- Do not modify custom RTL unless hardware testing proves a real RTL issue.
- Remember reset is external active-low PMOD JA4/G2, not CPU_RESETN/C12.
- Do not claim board success without observed UART responses.
