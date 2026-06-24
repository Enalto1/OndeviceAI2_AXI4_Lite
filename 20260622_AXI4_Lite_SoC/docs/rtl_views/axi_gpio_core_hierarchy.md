# `axi_gpio_core` RTL Hierarchy

Prompt 2 implemented the GPIO RTL wrapper and one adapted debounce helper. No simulation, UVM, Vivado project, or software was created.

## Implemented Files

| File | Purpose |
| --- | --- |
| `rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v` | AXI4-Lite GPIO wrapper for Basys3 LEDs, switches, and buttons. |
| `rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v` | Adapted debounce helper based on the reference `button_debounce.v`, with stable level and rising pulse outputs. |

## RTL Hierarchy

```text
axi_gpio_core
  u_btn_db0 : button_debounce_level
  u_btn_db1 : button_debounce_level
  u_btn_db2 : button_debounce_level
  u_btn_db3 : button_debounce_level
  u_btn_db4 : button_debounce_level
```

The five debounce instances are explicit instances, not generated instances.

## Signal Mapping

| Source | Destination | Purpose |
| --- | --- | --- |
| `sw_i[15:0]` | `sw_sync_0`, then `sw_sync_1` | Two-stage synchronization of external switches. |
| `sw_sync_1[15:0]` | `GPIO_IN[15:0]` | Synchronized switch readback. |
| `btn_i[4:0]` | `btn_sync_0`, then `btn_sync_1` | Two-stage synchronization of raw external buttons. |
| `btn_sync_1[4:0]` | `GPIO_IN[25:21]` | Synchronized raw button readback. |
| `btn_sync_1[n]` | `u_btn_dbn.i_btn` | Debounce input path. Synchronized button values feed debounce helpers. |
| `u_btn_dbn.o_btn_level` | `GPIO_IN[16+n]` | Stable debounced button level readback. |
| `u_btn_dbn.o_btn_pulse` | `BTN_EDGE[n]` set path | Rising pulse latches edge flag. |
| `GPIO_OUT[15:0]` | `led_o[15:0]` | LED output drive. |
| `BTN_EDGE_CLR[4:0]` | `btn_edge_reg[4:0]` clear mask | Write-one-to-clear selected edge flags. |

## Register Decode Summary

| Offset | Register | Implemented behavior |
| --- | --- | --- |
| `0x00` | `GPIO_OUT` | RW LED register. `WSTRB[0]` controls bits `[7:0]`; `WSTRB[1]` controls bits `[15:8]`. |
| `0x04` | `GPIO_IN` | RO synchronized switches, debounced button levels, and synchronized raw buttons. |
| `0x08` | `GPIO_SET` | WO set mask, reads as `0`. |
| `0x0C` | `GPIO_CLR` | WO clear mask, reads as `0`. |
| `0x10` | `GPIO_TOGGLE` | WO toggle mask, reads as `0`. |
| `0x14` | `BTN_EDGE` | RO latched edge flags. |
| `0x18` | `BTN_EDGE_CLR` | WO clear mask, reads as `0`. |
| `0x1C` | `VERSION` | RO fixed `32'h0001_0000`. |
| `0x20` to `0x3C` | Reserved | Reads `0`, writes ignored. |

## Edge/Clear Priority

If a debounced button pulse and a software clear for the same bit occur in the same clock, the implementation preserves the new event:

```text
btn_edge_next = (btn_edge_reg & ~clear_mask) | btn_pulse
```

This means the pulse set path wins over a simultaneous clear for that bit, avoiding loss of a button event.

## AXI Template Notes

The wrapper keeps the familiar Xilinx AXI4-Lite slave template shape:

- Single outstanding write transaction using `aw_en`.
- AW/W handshakes accepted together.
- OKAY write and read responses.
- Registered read data.
- Register map implemented through local offset decode.

The actual register write/read decode uses the current valid AXI address during the accepted handshake so the first access after reset cannot use stale latched address state.
