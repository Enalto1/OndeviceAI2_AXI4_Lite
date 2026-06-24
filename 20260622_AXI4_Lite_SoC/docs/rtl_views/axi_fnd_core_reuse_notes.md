# axi_fnd_core Reuse Notes

## Reference Source

`axi_fnd_core` must reuse:

```text
axi_project_unique_sources/sources/fnd_controller.v
```

The reference RTL directory remains read-only. Prompt 4 inspected the file but did not modify it.

SHA256 at Prompt 4 inspection:

```text
BF600178EADCA5689ED03A6054ADFA6FC5A423B4E872021CD6DBD664BB8C1519
```

## Actual Interface

The inspected top-level module is:

```verilog
module fnd_controller #(
    parameter DIV_COUNT     = 50_000,
    parameter DOT_THRESHOLD = 50,
    parameter MSEC_WIDTH    = 7,
    parameter SEC_WIDTH     = 6,
    parameter MIN_WIDTH     = 6,
    parameter HOUR_WIDTH    = 5,
    parameter DIST_WIDTH    = 9,
    parameter DHT_WIDTH     = 8
) (
    input clk,
    input rst,
    input [1:0] i_main_mode,
    input i_display_sel,
    input [MSEC_WIDTH-1:0] msec,
    input [SEC_WIDTH-1:0] sec,
    input [MIN_WIDTH-1:0] min,
    input [HOUR_WIDTH-1:0] hour,
    input [DIST_WIDTH-1:0] distance,
    input [DHT_WIDTH-1:0] humidity,
    input [DHT_WIDTH-1:0] temperature,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
```

This matches the expected Prompt 4 interface, including parameter names and widths.

## Reset And Clocking

- `rst` is active high.
- `clk_div_1khz` and `counter_8` use active-high reset.
- `clk_div_1khz` uses an asynchronous reset sensitivity list.
- The future AXI wrapper should drive `clk` from `s00_axi_aclk` and `rst` from `~s00_axi_aresetn`.

## Output Polarity

The output encoding is active-low:

- `decoder_2x4` drives active-low digit enables: `1110`, `1101`, `1011`, `0111`.
- `bcd` drives active-low segment values such as `8'hC0` for digit 0 and `8'hFF` for blank/off.
- `4'b1111` and `8'hFF` are the recommended wrapper-disabled blank values.

## Helper Modules

The same file declares these helpers:

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

`clk_div_1khz` uses `$clog2(DIV_COUNT)`, which is supported by Vivado 2020.2 for this use case but should still be covered by the future wrapper compile/simulation step.

## Display Mode Mapping

The internal mode constants are:

| `i_main_mode` | Reference name | Behavior |
| --- | --- | --- |
| `2'b00` | `MODE_STW` | Timer display path. |
| `2'b01` | `MODE_WTC` | Timer display path. |
| `2'b10` | `MODE_ULT` | Ultrasonic distance display path. |
| `2'b11` | `MODE_DHT` | DHT humidity/temperature display path. |

For both `MODE_STW` and `MODE_WTC`, the controller uses the timer display path. `i_display_sel` selects msec/sec versus min/hour. For DHT mode, `i_display_sel` selects humidity versus temperature. For ultrasonic mode, `i_display_sel` is ignored by the controller's distance path.

## Wrapper Reuse Plan

The future `axi_fnd_core` wrapper should:

1. Instantiate `fnd_controller`.
2. Hold `CONTROL`, `TIMER_VALUE`, and `SENSOR_VALUE` registers.
3. Connect register fields to `i_main_mode`, `i_display_sel`, `msec`, `sec`, `min`, `hour`, `distance`, `humidity`, and `temperature`.
4. Gate `fnd_com` and `fnd_data` with `display_enable`.
5. Expose gated outputs as `fnd_com_o` and `fnd_data_o`.
6. Read back the final gated outputs through `FND_OUTPUT`.

## Reuse Conclusion

`fnd_controller.v` is reusable as-is. No adapted copy is needed for the first `axi_fnd_core` version.
## Prompt 5 Implementation Decision

Prompt 5 implemented the AXI wrapper at:

```text
rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v
```

Implementation facts:

- The wrapper instantiates `fnd_controller` as `u_fnd_controller`.
- `clk` is driven by `s00_axi_aclk`.
- `rst` is driven by `~s00_axi_aresetn`.
- `CONTROL`, `TIMER_VALUE`, and `SENSOR_VALUE` register fields drive the documented controller inputs.
- Raw controller outputs are named `fnd_com_raw` and `fnd_data_raw`.
- Final outputs are gated by `CONTROL[0] display_enable`.
- No adapted copy of `fnd_controller.v` was needed.
- The reference `axi_project_unique_sources/sources/fnd_controller.v` remains unchanged.

Vivado simulation remains pending for the next step.