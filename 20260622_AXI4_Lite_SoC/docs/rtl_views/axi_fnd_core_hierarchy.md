# axi_fnd_core RTL Hierarchy

## Scope

Prompt 5 implements the `axi_fnd_core` RTL wrapper only. It does not create a Vivado simulation testbench, UVM environment, MicroBlaze software, or Vivado block design.

## RTL File

```text
rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v
```

## Hierarchy

```text
axi_fnd_core
  -> u_fnd_controller : fnd_controller
       -> mux_2x1
       -> mux_3x1
       -> mux_4x1
       -> mux_8x1
       -> digit_splitter
       -> digit_splitter_100
       -> bcd
       -> clk_div_1khz
       -> counter_8
       -> decoder_2x4
       -> dot_indicator
```

The helper modules are declared inside the unchanged reference file:

```text
axi_project_unique_sources/sources/fnd_controller.v
```

## Instance

The wrapper instantiates the reference controller as:

```text
u_fnd_controller : fnd_controller
```

Parameter pass-throughs:

| Wrapper parameter | Connected reference parameter | Default |
| --- | --- | --- |
| `FND_DIV_COUNT` | `DIV_COUNT` | `50_000` |
| `FND_DOT_THRESHOLD` | `DOT_THRESHOLD` | `50` |

All width parameters in `fnd_controller` remain at their documented defaults.

## Register-To-Port Mapping

| Wrapper register field | Reference controller port |
| --- | --- |
| `CONTROL[2:1] main_mode` | `i_main_mode` |
| `CONTROL[3] display_sel` | `i_display_sel` |
| `TIMER_VALUE[6:0] msec` | `msec` |
| `TIMER_VALUE[12:7] sec` | `sec` |
| `TIMER_VALUE[18:13] min` | `min` |
| `TIMER_VALUE[23:19] hour` | `hour` |
| `SENSOR_VALUE[8:0] distance` | `distance` |
| `SENSOR_VALUE[16:9] humidity` | `humidity` |
| `SENSOR_VALUE[24:17] temperature` | `temperature` |

## Output Path

The reused controller produces raw active-low outputs:

```text
fnd_com_raw
fnd_data_raw
```

The wrapper applies `CONTROL[0] display_enable` gating:

```text
display_enable = 0 -> fnd_com_o = 4'b1111, fnd_data_o = 8'hFF
display_enable = 1 -> fnd_com_o = fnd_com_raw, fnd_data_o = fnd_data_raw
```

`FND_OUTPUT` reads the final gated output pins:

```text
{16'h0000, fnd_data_o[7:0], 4'h0, fnd_com_o[3:0]}
```

## Reset And Blanking

The wrapper converts the AXI active-low reset to active-high reset:

```text
rst = ~s00_axi_aresetn
```

On reset:

- `CONTROL[3:0]` clears to zero.
- `TIMER_VALUE[23:0]` clears to zero.
- `SENSOR_VALUE[24:0]` clears to zero.
- `display_enable` is zero.
- Final FND outputs are blanked through wrapper gating.

## Register Summary

| Offset | Register | Access | Implemented behavior |
| --- | --- | --- | --- |
| `0x00` | `CONTROL` | RW | Byte-0 WSTRB updates bits `[3:0]`; upper bits read zero. |
| `0x04` | `TIMER_VALUE` | RW | WSTRB byte lanes 0..2 update bits `[23:0]`; byte 3 ignored. |
| `0x08` | `SENSOR_VALUE` | RW | WSTRB lanes 0..2 update bits `[23:0]`; lane 3 updates bit `[24]` only. |
| `0x0C` | `FND_OUTPUT` | RO | Reads final gated outputs; writes ignored. |
| `0x10`, `0x14`, `0x18` | Reserved | Reserved | Reads zero, writes ignored. |
| `0x1C` | `VERSION` | RO | Reads `32'h0001_0000`; writes ignored. |
| `0x20` to `0x3C` | Reserved | Reserved | Reads zero, writes ignored. |

## Reference RTL Status

`fnd_controller.v` remains unchanged. No adapted FND controller copy was created.

## Verification Status

Vivado simulation for `axi_fnd_core` is still pending and should be created in the next verification step.