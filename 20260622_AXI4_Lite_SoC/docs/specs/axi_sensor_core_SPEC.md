# axi_sensor_core Specification

## Scope

`axi_sensor_core` is the AXI4-Lite sensor peripheral for the Basys3-first MicroBlaze SoC. It wraps the existing HC-SR04 ultrasonic controller and DHT11 controller as independent sensor channels behind software-visible AXI registers.

This specification is based on direct inspection of:

```text
axi_project_unique_sources/sources/sr04.v
axi_project_unique_sources/sources/dht11.v
```

Prompt 10 creates the specification package only before RTL implementation. Reference RTL remains read-only.

## Address Assignment

| Item | Value |
| --- | --- |
| Peripheral | `axi_sensor_core` |
| Base address | `0x44A3_0000` |
| High address | `0x44A3_FFFF` |
| Range | 64 KB |
| Local AXI address width | 6 bits |
| Local register offsets | `0x00` to `0x3C` |
| AXI data width | 32 bits |
| Vivado target assumption | Vivado 2020.2 |

## External Non-AXI Ports

The first wrapper exposes only the board-facing sensor pins needed by the inspected reference RTL:

| Port | Direction | Width | Description |
| --- | --- | --- | --- |
| `sr04_echo_i` | input | 1 | HC-SR04 echo input, connected to `sr04.echo`. |
| `sr04_trig_o` | output | 1 | HC-SR04 trigger output, driven by `sr04.trig`. |
| `dht11_io` | inout | 1 | DHT11 single-wire data line, connected to `dht11.dht11`. |

## Reference RTL Interface

### `sr04`

Actual top-level module interface:

```verilog
module sr04 (
    input        clk,
    input        rst,
    input        ultra_btn,
    input        echo,
    output [8:0] distance,
    output       trig
);
```

Wrapper mapping:

| Reference port | Wrapper signal |
| --- | --- |
| `clk` | `s00_axi_aclk` |
| `rst` | `~s00_axi_aresetn` |
| `ultra_btn` | one-clock `sr04_start_pulse`, gated by `CONTROL[0]` |
| `echo` | `sr04_echo_i` |
| `distance` | `sr04_distance[8:0]` and `SR04_VALUE[8:0]` |
| `trig` | `sr04_trig_o` and `STATUS[0]` |

`sr04.v` includes an internal `tick_gen_us` with parameter `F_COUNT = 100_000_000 / 1_000_000`.

### `dht11`

Actual top-level module interface:

```verilog
module dht11 (
    input        clk,
    input        rst,
    input        dht_btn,
    output       led,
    output [7:0] hm,
    output [7:0] tm,
    inout        dht11
);
```

Wrapper mapping:

| Reference port | Wrapper signal |
| --- | --- |
| `clk` | `s00_axi_aclk` |
| `rst` | `~s00_axi_aresetn` |
| `dht_btn` | one-clock `dht_start_pulse`, gated by `CONTROL[8]` |
| `led` | `dht_valid_live` and `STATUS[8]` |
| `hm` | `dht_humidity[7:0]` and `DHT_VALUE[7:0]` |
| `tm` | `dht_temperature[7:0]` and `DHT_VALUE[15:8]` |
| `dht11` | `dht11_io` |

`dht11.v` includes an internal `tick_gen_us_dht11` with parameter `F_COUNT = 100_000_000 / 1_000_000`.

The inspected `dht11` top exposes `led` as the only live validity indication. The first wrapper maps this to `dht_valid_live`. Full DHT11 transaction modeling is a simulation concern, not a register-map ambiguity.

## Sensor And FND Decoupling Policy

`axi_sensor_core` remains independent from `axi_fnd_core`.

- It does not instantiate `fnd_controller`.
- It does not instantiate `axi_fnd_core`.
- It does not directly drive FND pins.
- MicroBlaze software will later read `axi_sensor_core` values and write `axi_fnd_core` display registers if display output is needed.

## Register Map Summary

| Offset | Absolute address | Register | Access | Reset | Description |
| --- | --- | --- | --- | --- | --- |
| `0x00` | `0x44A3_0000` | `CONTROL` | RW | `0x0000_0000` | SR04 and DHT enable bits. |
| `0x04` | `0x44A3_0004` | `COMMAND` | WO | reads `0x0000_0000` | Start pulses for SR04 and DHT11. |
| `0x08` | `0x44A3_0008` | `SR04_VALUE` | RO | dynamic | 9-bit ultrasonic distance. |
| `0x0C` | `0x44A3_000C` | `DHT_VALUE` | RO | dynamic | DHT humidity and temperature bytes. |
| `0x10` | `0x44A3_0010` | `STATUS` | RO | dynamic | Live sensor status and enable mirrors. |
| `0x14` | `0x44A3_0014` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |
| `0x18` | `0x44A3_0018` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |
| `0x1C` | `0x44A3_001C` | `VERSION` | RO | `0x0001_0000` | Fixed peripheral version. |
| `0x20` to `0x3C` | `0x44A3_0020` to `0x44A3_003C` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |

## Register Details

### CONTROL - Offset `0x00`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[0]` | `sr04_enable` | RW | `0` | Enables `COMMAND[0]` to generate `sr04_start_pulse`. |
| `[7:1]` | reserved | RO | `0` | Reads zero. |
| `[8]` | `dht_enable` | RW | `0` | Enables `COMMAND[8]` to generate `dht_start_pulse`. |
| `[31:9]` | reserved | RO | `0` | Reads zero. |

### COMMAND - Offset `0x04`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[0]` | `sr04_start` | WO | n/a | Write `1` creates one `s00_axi_aclk` cycle `sr04_start_pulse` only when `sr04_enable = 1`. |
| `[8]` | `dht_start` | WO | n/a | Write `1` creates one `s00_axi_aclk` cycle `dht_start_pulse` only when `dht_enable = 1`. |
| other | reserved | WO | n/a | Writes have no effect. |

`COMMAND` has no stored state and always reads `32'h0000_0000`.

### SR04_VALUE - Offset `0x08`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[8:0]` | `distance` | RO | `sr04.distance`. |
| `[31:9]` | reserved | RO | Reads zero. |

### DHT_VALUE - Offset `0x0C`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[7:0]` | `humidity` | RO | `dht11.hm`. |
| `[15:8]` | `temperature` | RO | `dht11.tm`. |
| `[31:16]` | reserved | RO | Reads zero. |

### STATUS - Offset `0x10`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[0]` | `sr04_trig_live` | RO | Live `sr04.trig` output. |
| `[8]` | `dht_valid_live` | RO | Live `dht11.led` validity output. |
| `[16]` | `sr04_enable` | RO | Mirror of `CONTROL[0]`. |
| `[24]` | `dht_enable` | RO | Mirror of `CONTROL[8]`. |
| other | reserved | RO | Reads zero. |

### VERSION - Offset `0x1C`

`VERSION` always reads `32'h0001_0000`. Writes have no effect.

## WSTRB Policy

`CONTROL`:

- `WSTRB[0]` updates `CONTROL[0]`.
- `WSTRB[1]` updates `CONTROL[8]`.
- `WSTRB[2]` and `WSTRB[3]` have no visible effect.

`COMMAND`:

- `WSTRB[0]` enables `COMMAND[0]`.
- `WSTRB[1]` enables `COMMAND[8]`.
- `WSTRB[2]` and `WSTRB[3]` have no visible effect.

Read-only and reserved registers ignore writes.

## Behavioral Requirements

- Reset clears `CONTROL`, command pulses, and reused sensor modules.
- Start command pulses are one `s00_axi_aclk` cycle wide.
- `sr04_start_pulse` is blocked unless `sr04_enable = 1`.
- `dht_start_pulse` is blocked unless `dht_enable = 1`.
- `SR04_VALUE` is determined only by `sr04.distance`.
- `DHT_VALUE` is determined only by `dht11.hm` and `dht11.tm`.
- Reserved offsets return zero and ignore writes.
- AXI responses are `OKAY` for implemented and reserved offsets.

## Simulation Runtime Notes

Both reference sensor files use internal 1 us tick generators. At 100 MHz, each microsecond tick takes 100 cycles by default. For focused Vivado simulation, use testbench-only hierarchical `defparam` overrides if supported:

```verilog
defparam dut.u_sr04.U_TICK_GEN_SR04.F_COUNT = 4;
defparam dut.u_dht11.U_TICK_GEN_US.F_COUNT = 4;
```

DHT11 full protocol modeling is more involved because the reference controller expects the bidirectional DHT11 sensor response waveform. The basic unattended simulation may verify compile, AXI registers, command gating, start-line behavior, live status, and reserved/read-only behavior without claiming full DHT11 protocol coverage.

## Specification Decision

No critical interface ambiguity blocks the first RTL wrapper. The actual source interfaces are documented above, and `dht11.led` is used as the exposed live valid status.
