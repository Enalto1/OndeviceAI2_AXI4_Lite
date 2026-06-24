# axi_fnd_core Specification

## Scope

`axi_fnd_core` is the AXI4-Lite FND display peripheral for the Basys3-first MicroBlaze SoC.

This specification defines the register map, reset behavior, external ports, reuse policy, software-visible behavior, and later verification expectations only. Prompt 4 does not implement RTL, create a testbench, create UVM, create MicroBlaze software, or create a Vivado block design.

## Address Assignment

| Item | Value |
| --- | --- |
| Peripheral | `axi_fnd_core` |
| Base address | `0x44A1_0000` |
| High address | `0x44A1_FFFF` |
| Range | 64 KB |
| Local AXI address width | 6 bits |
| Local register offsets | `0x00` to `0x3C` |
| AXI data width | 32 bits |
| Vivado target assumption | Vivado 2020.2 |

## Future Wrapper Interface Assumptions

The future wrapper should follow the same Vivado 2020.2 Xilinx AXI4-Lite slave template style used for `axi_gpio_core`.

| Signal or parameter | Requirement |
| --- | --- |
| AXI clock | `s00_axi_aclk` |
| AXI reset | `s00_axi_aresetn`, active low |
| Internal reset | `rst = ~s00_axi_aresetn`, active high |
| AXI response | `OKAY` for implemented and reserved accesses |
| Local register decode | 32-bit aligned offsets inside the 6-bit local window |

## External Non-AXI Ports

| Port | Direction | Width | Description | Reset or disabled behavior |
| --- | --- | --- | --- | --- |
| `fnd_com_o` | output wire | 4 | Basys3 FND common-anode digit select pins. The reused controller drives active-low enables. | `4'b1111` when reset or `display_enable = 0` |
| `fnd_data_o` | output wire | 8 | Basys3 FND segment/dot data pins. The reused controller drives active-low segment data. | `8'hFF` when reset or `display_enable = 0` |

The disabled behavior blanks the display under the active-low Basys3 FND convention.

## Reference RTL Inspection

Source inspected:

```text
axi_project_unique_sources/sources/fnd_controller.v
```

SHA256 at Prompt 4 inspection:

```text
BF600178EADCA5689ED03A6054ADFA6FC5A423B4E872021CD6DBD664BB8C1519
```

### Top Module

The top module is `fnd_controller`.

Parameter defaults:

| Parameter | Default | Purpose |
| --- | --- | --- |
| `DIV_COUNT` | `50_000` | Divider terminal count for the scan clock helper. |
| `DOT_THRESHOLD` | `50` | Msec threshold for dot-on indication. |
| `MSEC_WIDTH` | `7` | Width of the `msec` input. |
| `SEC_WIDTH` | `6` | Width of the `sec` input. |
| `MIN_WIDTH` | `6` | Width of the `min` input. |
| `HOUR_WIDTH` | `5` | Width of the `hour` input. |
| `DIST_WIDTH` | `9` | Width of the `distance` input. |
| `DHT_WIDTH` | `8` | Width of `humidity` and `temperature` inputs. |

Top-level ports:

| Port | Direction | Width | Notes |
| --- | --- | --- | --- |
| `clk` | input | 1 | FND controller clock. Future wrapper should drive this from `s00_axi_aclk`. |
| `rst` | input | 1 | Active-high reset. Passed into the clock divider and digit counter helpers. |
| `i_main_mode` | input | 2 | Selects timer/watch, ultrasonic, or DHT display path. |
| `i_display_sel` | input | 1 | Selects timer low/high view or DHT humidity/temperature view. |
| `msec` | input | `MSEC_WIDTH` | Timer value input. |
| `sec` | input | `SEC_WIDTH` | Timer value input. |
| `min` | input | `MIN_WIDTH` | Timer value input. |
| `hour` | input | `HOUR_WIDTH` | Timer value input. |
| `distance` | input | `DIST_WIDTH` | Ultrasonic distance value input. |
| `humidity` | input | `DHT_WIDTH` | DHT humidity value input. |
| `temperature` | input | `DHT_WIDTH` | DHT temperature value input. |
| `fnd_com` | output | 4 | Active-low digit select; helper maps digits to `1110`, `1101`, `1011`, `0111`. |
| `fnd_data` | output | 8 | Active-low segment/dot data; `8'hFF` is blank/off. |

### Helper Modules In The Same File

The file declares these helper modules after `fnd_controller`:

- `mux_2x1`
- `mux_3x1`
- `mux_4x1`
- `mux_8x1`
- `digit_splitter`
- `digit_splitter_100`
- `bcd`
- `clk_div_1khz`
- `counter_8`
- `decoder_2x4`
- `dot_indicator`

The file uses `$clog2` in `clk_div_1khz`.

### Reuse Conclusion

`fnd_controller.v` is reusable as-is for the first `axi_fnd_core` version. The future wrapper should instantiate `fnd_controller`, connect software-controlled register fields to its inputs, and gate its outputs with `display_enable`. The reference file must remain unchanged.

## Integration Policy

The first `axi_fnd_core` uses a decoupled software-updated display model:

1. `axi_fnd_core` does not directly connect to `axi_timer_core` or `axi_sensor_core` in hardware.
2. MicroBlaze software will later read timer/sensor values and write display values into `axi_fnd_core`.
3. This keeps peripheral wrappers independent and easier to simulate.
4. Optional direct hardware display-source muxing is deferred to a future enhancement.

## Register Map Summary

| Offset | Absolute address | Register | Access | Reset | Description |
| --- | --- | --- | --- | --- | --- |
| `0x00` | `0x44A1_0000` | `CONTROL` | RW | `0x0000_0000` | Enable, display mode, and display select. |
| `0x04` | `0x44A1_0004` | `TIMER_VALUE` | RW | `0x0000_0000` | Software-updated msec/sec/min/hour fields. |
| `0x08` | `0x44A1_0008` | `SENSOR_VALUE` | RW | `0x0000_0000` | Software-updated distance/humidity/temperature fields. |
| `0x0C` | `0x44A1_000C` | `FND_OUTPUT` | RO | dynamic | Final gated FND output monitor. |
| `0x10` | `0x44A1_0010` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |
| `0x14` | `0x44A1_0014` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |
| `0x18` | `0x44A1_0018` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |
| `0x1C` | `0x44A1_001C` | `VERSION` | RO | `0x0001_0000` | Fixed peripheral version. |
| `0x20` to `0x3C` | `0x44A1_0020` to `0x44A1_003C` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |

## Register Details

### CONTROL - Offset `0x00`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[0]` | `display_enable` | RW | `0` | `0` blanks the FND outputs. `1` drives outputs from `fnd_controller`. |
| `[2:1]` | `main_mode` | RW | `2'b00` | `00`: stopwatch/timer display. `01`: watch/timer display. `10`: ultrasonic distance display. `11`: DHT11 display. |
| `[3]` | `display_sel` | RW | `0` | Timer mode: `0` msec/sec, `1` min/hour. DHT mode: `0` humidity, `1` temperature. Ultrasonic mode: ignored. |
| `[31:4]` | reserved | RO | `0` | Reads as zero. Writes have no effect. |

`main_mode` drives `fnd_controller.i_main_mode`. `display_sel` drives `fnd_controller.i_display_sel`.

### TIMER_VALUE - Offset `0x04`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[6:0]` | `msec` | RW | `0` | Drives `fnd_controller.msec`. |
| `[12:7]` | `sec` | RW | `0` | Drives `fnd_controller.sec`. |
| `[18:13]` | `min` | RW | `0` | Drives `fnd_controller.min`. |
| `[23:19]` | `hour` | RW | `0` | Drives `fnd_controller.hour`. |
| `[31:24]` | reserved | RO | `0` | Reads as zero. Writes have no effect. |

### SENSOR_VALUE - Offset `0x08`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[8:0]` | `distance` | RW | `0` | Drives `fnd_controller.distance`. |
| `[16:9]` | `humidity` | RW | `0` | Drives `fnd_controller.humidity`. |
| `[24:17]` | `temperature` | RW | `0` | Drives `fnd_controller.temperature`. |
| `[31:25]` | reserved | RO | `0` | Reads as zero. Writes have no effect. |

### FND_OUTPUT - Offset `0x0C`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[3:0]` | `fnd_com_current` | RO | dynamic | Final `fnd_com_o` value after `display_enable` gating. |
| `[7:4]` | reserved | RO | `0` | Reads as zero. |
| `[15:8]` | `fnd_data_current` | RO | dynamic | Final `fnd_data_o` value after `display_enable` gating. |
| `[31:16]` | reserved | RO | `0` | Reads as zero. |

Writes to `FND_OUTPUT` have no effect.

### VERSION - Offset `0x1C`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[31:0]` | `version` | RO | `0x0001_0000` | Fixed first-version identifier. |

Writes to `VERSION` have no effect.

## Reset And Behavioral Requirements

1. Reset clears `CONTROL` to zero.
2. Reset clears `TIMER_VALUE` to zero.
3. Reset clears `SENSOR_VALUE` to zero.
4. Reset disables the display output.
5. When `display_enable = 0`, `fnd_com_o = 4'b1111` and `fnd_data_o = 8'hFF`.
6. When `display_enable = 1`, `fnd_com_o` and `fnd_data_o` come from the reused `fnd_controller`.
7. `CONTROL.main_mode` and `CONTROL.display_sel` drive `i_main_mode` and `i_display_sel`.
8. `TIMER_VALUE` fields drive `msec`, `sec`, `min`, and `hour`.
9. `SENSOR_VALUE` fields drive `distance`, `humidity`, and `temperature`.
10. `FND_OUTPUT` readback reflects final wrapper pins after enable gating.
11. `VERSION` remains fixed at `32'h0001_0000`.
12. Reserved bits read as zero.
13. Reserved writes have no effect.
14. Read-only registers ignore writes.
15. No write-only registers are needed for this first version.

## Software Value Ranges

The first RTL version should not add range checking unless explicitly requested later. Software should still use the recommended ranges below.

| Field | Register width | Recommended software range | Notes |
| --- | --- | --- | --- |
| `msec` | 7 bits | 0 to 99 | Decimal digits generated by `digit_splitter`. |
| `sec` | 6 bits | 0 to 59 | No RTL range check planned. |
| `min` | 6 bits | 0 to 59 | No RTL range check planned. |
| `hour` | 5 bits | 0 to 23 | No RTL range check planned. |
| `distance` | 9 bits | 0 to 511 by register width | Conceptually 0 to 999 displayable, but the existing interface is 9 bits. |
| `humidity` | 8 bits | 0 to 99 | No RTL range check planned. |
| `temperature` | 8 bits | 0 to 99 | No RTL range check planned. |

## WSTRB Policy

Writable registers must respect AXI `WSTRB`:

- `CONTROL`, `TIMER_VALUE`, and `SENSOR_VALUE` are writable.
- Only strobed byte lanes update.
- Unstrobed byte lanes retain their previous meaningful bits.
- Reserved bits are not stored and always read as zero.
- Writes to `FND_OUTPUT`, `VERSION`, and reserved offsets have no effect.

Meaningful byte lanes:

| Register | Meaningful byte lanes |
| --- | --- |
| `CONTROL` | Byte 0 only. |
| `TIMER_VALUE` | Bytes 0, 1, and 2. Byte 3 is reserved. |
| `SENSOR_VALUE` | Bytes 0, 1, 2, and bit 24 of byte 3. Bits `[31:25]` remain reserved. |

## Future RTL Notes

- Instantiate the existing `fnd_controller` from `axi_project_unique_sources/sources/fnd_controller.v`; do not recreate it.
- Use wrapper registers to drive the controller inputs.
- Add wrapper-side output gating for `display_enable`.
- Keep direct cross-peripheral wiring out of this first version.
- Follow the same AXI4-Lite template style and reset convention as `axi_gpio_core`.
- Keep UVM deferred until all custom AXI4-Lite peripherals are implemented and have basic Vivado simulation results.