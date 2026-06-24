# `axi_gpio_core` Specification

Prompt 1 specifies `axi_gpio_core` only. No RTL wrapper is implemented in this step.

## Purpose

`axi_gpio_core` is the first planned custom AXI4-Lite peripheral. It provides MicroBlaze software control of Basys3 LEDs and readback of Basys3 switches/buttons through AXI registers.

## Base Address

| Item | Value |
| --- | --- |
| Planned base address | `0x44A0_0000` |
| Planned high address | `0x44A0_FFFF` |
| Vivado range | 64 KB |
| Local register offsets | `0x00` to `0x3C` |
| Local AXI address width | 6 bits |

## External Ports

### Non-AXI Ports

| Port | Direction | Width | Description | Synchronization/debounce policy |
| --- | --- | --- | --- | --- |
| `sw_i` | input wire | 16 | Basys3 switch inputs. | External asynchronous input; synchronize before register readback. |
| `btn_i` | input wire | 5 | Basys3 button inputs. | External asynchronous input; synchronize raw values and debounce before edge detection/readback. |
| `led_o` | output wire | 16 | Basys3 LED outputs. | Driven directly from `GPIO_OUT[15:0]`. |

### AXI4-Lite Ports

Future RTL should use Xilinx AXI4-Lite slave template naming. Planned AXI ports:

| Port | Direction | Width | Description |
| --- | --- | --- | --- |
| `s00_axi_aclk` | input | 1 | AXI clock. |
| `s00_axi_aresetn` | input | 1 | AXI reset, active low. Internal legacy reset should be `rst = ~s00_axi_aresetn`. |
| `s00_axi_awaddr` | input | 6 | Write address. |
| `s00_axi_awprot` | input | 3 | Write protection. Preserved from template. |
| `s00_axi_awvalid` | input | 1 | Write address valid. |
| `s00_axi_awready` | output | 1 | Write address ready. |
| `s00_axi_wdata` | input | 32 | Write data. |
| `s00_axi_wstrb` | input | 4 | Write byte strobes. |
| `s00_axi_wvalid` | input | 1 | Write data valid. |
| `s00_axi_wready` | output | 1 | Write data ready. |
| `s00_axi_bresp` | output | 2 | Write response. |
| `s00_axi_bvalid` | output | 1 | Write response valid. |
| `s00_axi_bready` | input | 1 | Write response ready. |
| `s00_axi_araddr` | input | 6 | Read address. |
| `s00_axi_arprot` | input | 3 | Read protection. Preserved from template. |
| `s00_axi_arvalid` | input | 1 | Read address valid. |
| `s00_axi_arready` | output | 1 | Read address ready. |
| `s00_axi_rdata` | output | 32 | Read data. |
| `s00_axi_rresp` | output | 2 | Read response. |
| `s00_axi_rvalid` | output | 1 | Read data valid. |
| `s00_axi_rready` | input | 1 | Read data ready. |

## Register Map

| Offset | Name | Access | Reset value | Description |
| --- | --- | --- | --- | --- |
| `0x00` | `GPIO_OUT` | `RW` | `0x0000_0000` | LED output register. |
| `0x04` | `GPIO_IN` | `RO` | dynamic | Switch/button input readback. |
| `0x08` | `GPIO_SET` | `WO` | N/A | Write-one-to-set LED bits. |
| `0x0C` | `GPIO_CLR` | `WO` | N/A | Write-one-to-clear LED bits. |
| `0x10` | `GPIO_TOGGLE` | `WO` | N/A | Write-one-to-toggle LED bits. |
| `0x14` | `BTN_EDGE` | `RO` | `0x0000_0000` | Debounced button rising-edge flags. |
| `0x18` | `BTN_EDGE_CLR` | `WO` | N/A | Write-one-to-clear button edge flags. |
| `0x1C` | `VERSION` | `RO` | `0x0001_0000` | Initial IP version constant. |
| `0x20` to `0x3C` | Reserved | Reserved | `0x0000_0000` readback | Reads return `0`; writes have no effect. |

## Bit Definitions

### `GPIO_OUT` at `0x00`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[15:0]` | `led_value` | `RW` | `0x0000` | Drives `led_o[15:0]`. |
| `[31:16]` | reserved | `RO` | `0` | Reserved, read as `0`; writes ignored. |

### `GPIO_IN` at `0x04`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[15:0]` | `sw_sync` | `RO` | dynamic | Synchronized switch inputs. |
| `[20:16]` | `btn_debounced` | `RO` | dynamic | Debounced button level values. See debounce reuse note below. |
| `[25:21]` | `btn_raw_sync` | `RO` | dynamic | Synchronized raw button values before debounce. |
| `[31:26]` | reserved | `RO` | `0` | Reserved, read as `0`. |

### `GPIO_SET` at `0x08`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[15:0]` | `set_mask` | `WO` | Write `1` to set corresponding `GPIO_OUT` bit. Write `0` has no effect. |
| `[31:16]` | reserved | `WO` | Ignored. |

Reads from this register should return `0` if read access is allowed by the AXI template. Software should treat it as write-only.

### `GPIO_CLR` at `0x0C`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[15:0]` | `clr_mask` | `WO` | Write `1` to clear corresponding `GPIO_OUT` bit. Write `0` has no effect. |
| `[31:16]` | reserved | `WO` | Ignored. |

### `GPIO_TOGGLE` at `0x10`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[15:0]` | `toggle_mask` | `WO` | Write `1` to toggle corresponding `GPIO_OUT` bit. Write `0` has no effect. |
| `[31:16]` | reserved | `WO` | Ignored. |

### `BTN_EDGE` at `0x14`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[4:0]` | `btn_edge_flag` | `RO` | `0` | Rising edge of debounced button sets the corresponding flag. |
| `[31:5]` | reserved | `RO` | `0` | Reserved, read as `0`. |

Flags remain set until cleared through `BTN_EDGE_CLR`.

### `BTN_EDGE_CLR` at `0x18`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[4:0]` | `btn_edge_clr_mask` | `WO` | Write `1` to clear corresponding `BTN_EDGE` flag. Write `0` has no effect. |
| `[31:5]` | reserved | `WO` | Ignored. |

### `VERSION` at `0x1C`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[31:16]` | `version_major_minor` | `RO` | `0x0001` | Initial project/IP version. |
| `[15:0]` | `implementation_revision` | `RO` | `0x0000` | Initial implementation revision. |

Fixed initial read value: `0x0001_0000`.

## Required Behavior

1. Reset clears `GPIO_OUT` to `0`.
2. Reset clears `BTN_EDGE` to `0`.
3. `led_o[15:0]` follows `GPIO_OUT[15:0]`.
4. `GPIO_OUT` write updates the LED output register. With full `WSTRB`, it replaces all LED bits.
5. `GPIO_SET` modifies only bits written as `1`.
6. `GPIO_CLR` modifies only bits written as `1`.
7. `GPIO_TOGGLE` modifies only bits written as `1`.
8. `GPIO_IN` returns synchronized switch values, debounced button values, and synchronized raw button values.
9. `BTN_EDGE` captures rising edges of debounced button signals.
10. `BTN_EDGE_CLR` clears selected latched edge flags.
11. `VERSION` is read-only and fixed at `0x0001_0000`.
12. Reserved bits read as `0`.
13. Reserved writes have no effect.

## Write Conflict Policy

AXI4-Lite writes occur as one transaction to one decoded address at a time. Preferred implementation should decode one write address at a time, so there is no same-cycle conflict between `GPIO_SET`, `GPIO_CLR`, and `GPIO_TOGGLE`.

If a future implementation combines write enables internally, priority must be:

```text
GPIO_OUT direct write > GPIO_SET > GPIO_CLR > GPIO_TOGGLE
```

## Input Synchronization And Debounce Policy

- `sw_i` and `btn_i` are asynchronous to `s00_axi_aclk`.
- Switches should be synchronized before readback, preferably with at least two flip-flop stages per bit.
- Raw synchronized buttons should be exposed in `GPIO_IN[25:21]`.
- Debounced button level values should be exposed in `GPIO_IN[20:16]`.
- Rising edges of debounced button signals should latch `BTN_EDGE[4:0]`.

## `button_debounce.v` Reuse Conclusion

Actual reference file inspected:

```text
D:\OndeviceAI2_AXI4_Lite\axi_project_unique_sources\sources\button_debounce.v
```

Module and port list:

```verilog
module button_debounce(
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);
```

Observed behavior:

- Handles one button input.
- Uses active-high asynchronous reset in `always @(posedge clk, posedge rst)` and `always @(posedge clk_100khz, posedge rst)`.
- Samples `i_btn` into an 8-bit shift register on an internally generated sampling pulse/clock.
- Internal `debounce` level is high when all 8 sampled bits are high.
- `o_btn = debounce & (~edge_reg)`, so `o_btn` is a one-clock pulse on the rising edge of the debounced level, not a stable debounced button level.

Specification impact:

- Future `axi_gpio_core` should instantiate five explicit `button_debounce` instances if using this module for button press/rising-edge pulse generation.
- Do not use a generate loop unless later explicitly approved.
- `button_debounce.v` is compatible with `BTN_EDGE` pulse/flag generation.
- `button_debounce.v` is not directly compatible with `GPIO_IN[20:16] btn_debounced` level readback because it does not expose the stable debounced level.
- A later RTL step must choose and document one of these options:
  1. Add wrapper-side debounced level logic while reusing `button_debounce` for edge pulses.
  2. Copy `button_debounce.v` into a working RTL directory, rename it clearly, and adapt the copy to expose both debounced level and edge pulse.
  3. Revise the GPIO spec only if project requirements change and debounced level readback is no longer required.

The reference `button_debounce.v` must remain unchanged.

## AXI Register Behavior Notes

- AW/W/B and AR/R channels come from the Xilinx AXI4-Lite slave template.
- Preserve the AXI handshake logic from the template.
- Modify only register map decode, write behavior, read mux behavior, and GPIO core connections.
- Respect `WSTRB` for writable registers when supported by the template.
- Read-only registers ignore writes.
- Write-only command registers may read as `0`.
- Reserved addresses read as `0` and ignore writes.

## Implementation Non-Goals For Prompt 1

- No RTL was created.
- No AXI wrapper was created.
- No Vivado project was created.
- No simulation testbench was created.
- No UVM environment was created.
- No reference RTL source was modified.
