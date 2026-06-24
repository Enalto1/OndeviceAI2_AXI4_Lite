# AXI Register Conventions

This document defines register behavior conventions for custom AXI4-Lite slave peripherals in the project, starting with `axi_gpio_core`.

## AXI4-Lite Template Policy

- Future custom wrappers must use the Xilinx AXI4-Lite slave template style compatible with Vivado 2020.2.
- The AW/W/B write channels and AR/R read channels should preserve the generated template handshake logic.
- Wrapper work should focus on register decode, register write behavior, read mux behavior, one-clock pulse generation, and connections to reused RTL cores.
- Do not hand-write a new AXI protocol implementation from scratch.

## Standard Interface Assumptions

| Item | Assumption |
| --- | --- |
| AXI data width | 32 bits |
| Local AXI address width | 6 bits per custom peripheral |
| Vivado address range | 64 KB per custom peripheral |
| AXI clock | `s00_axi_aclk` |
| AXI reset | `s00_axi_aresetn`, active low |
| Legacy internal reset | `rst = ~s00_axi_aresetn`, active high |
| AXI response | `OKAY` for implemented and reserved register accesses unless a later spec says otherwise |

## Register Access Types

| Access | Meaning |
| --- | --- |
| `RW` | Software can read and write the register. |
| `RO` | Software can read the register; writes have no effect. |
| `WO` | Software writes command or mask data; reads should return `0` if the AXI template allows reads. |
| `Reserved` | Reads return `0`; writes have no effect. |

## WSTRB Policy

Writable registers should respect AXI `WSTRB` when the Xilinx template provides byte strobes:

- A byte lane updates only when its corresponding `WSTRB` bit is `1`.
- Unstrobed byte lanes retain their previous value or have no command effect.
- A full 32-bit MicroBlaze write normally uses `WSTRB = 4'b1111`.
- For command-mask registers such as `GPIO_SET`, `GPIO_CLR`, `GPIO_TOGGLE`, and `BTN_EDGE_CLR`, only strobed bytes should contribute command bits.
- For `axi_gpio_core`, meaningful LED bits are in byte lanes 0 and 1; meaningful button edge clear bits are in byte lane 0.

If a future implementation cannot support partial strobes cleanly, the limitation must be documented before RTL review.

## Reserved Bits And Addresses

- Reserved bits read as `0`.
- Writes to reserved bits have no effect.
- Reserved local offsets return `0`.
- Writes to reserved local offsets have no effect.
- Reserved behavior should be covered by simulation and UVM tests.

## Read-Only And Write-Only Policy

- Read-only status/data registers must not be software-writable.
- Write-only command registers may read as `0`.
- Software should not depend on readback from write-only command registers.
- Status flags that latch events should use explicit write-one-to-clear registers.

## One-Clock Pulse Policy

One-shot command fields should become one-clock pulses inside the wrapper:

- `start`
- `clear`
- `up`
- `down`
- `cmd_valid`
- write-one command masks

For `axi_gpio_core`, the command registers do not drive external pulse ports; instead, each AXI write transaction immediately modifies the LED or edge-flag state according to the addressed register.
