# axi_sensor_core RTL Hierarchy

## Scope

Phase B of the unattended run implements the `axi_sensor_core` RTL wrapper only. It does not create UVM, MicroBlaze software, or a Vivado block design.

## RTL File

```text
rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v
```

## Hierarchy

```text
axi_sensor_core
  -> u_sr04 : sr04
       -> U_SR04_CNTL : sr04_controller
       -> U_TICK_GEN_SR04 : tick_gen_us
  -> u_dht11 : dht11
       -> U_DHT11_CNTL : dht11_controller
       -> U_TICK_GEN_US : tick_gen_us_dht11
```

The reused modules are declared in unchanged reference files:

```text
axi_project_unique_sources/sources/sr04.v
axi_project_unique_sources/sources/dht11.v
```

## AXI Interface

- `C_S00_AXI_DATA_WIDTH = 32`
- `C_S00_AXI_ADDR_WIDTH = 6`
- `s00_axi_aclk`
- `s00_axi_aresetn`, active low
- Internal active-high reset: `rst = ~s00_axi_aresetn`

## External Pins

| Wrapper port | Reused module port |
| --- | --- |
| `sr04_echo_i` | `u_sr04.echo` |
| `sr04_trig_o` | `u_sr04.trig` |
| `dht11_io` | `u_dht11.dht11` |

## Register-To-Port Mapping

| Wrapper register field | Internal effect |
| --- | --- |
| `CONTROL[0] sr04_enable` | Enables `COMMAND[0]` to pulse `u_sr04.ultra_btn`. |
| `CONTROL[8] dht_enable` | Enables `COMMAND[8]` to pulse `u_dht11.dht_btn`. |
| `COMMAND[0] sr04_start` | One-clock `sr04_start_pulse` when enabled and `WSTRB[0] = 1`. |
| `COMMAND[8] dht_start` | One-clock `dht_start_pulse` when enabled and `WSTRB[1] = 1`. |
| `SR04_VALUE[8:0]` | `u_sr04.distance`. |
| `DHT_VALUE[7:0]` | `u_dht11.hm`. |
| `DHT_VALUE[15:8]` | `u_dht11.tm`. |
| `STATUS[0]` | Live `u_sr04.trig`. |
| `STATUS[8]` | Live `u_dht11.led` as `dht_valid_live`. |
| `STATUS[16]` | Mirror of `CONTROL[0]`. |
| `STATUS[24]` | Mirror of `CONTROL[8]`. |

## WSTRB Behavior

`CONTROL`:

- `WSTRB[0]` updates `CONTROL[0]`.
- `WSTRB[1]` updates `CONTROL[8]`.
- `WSTRB[2]` and `WSTRB[3]` have no visible effect.

`COMMAND`:

- `WSTRB[0]` enables `COMMAND[0]`.
- `WSTRB[1]` enables `COMMAND[8]`.
- `WSTRB[2]` and `WSTRB[3]` have no visible effect.

## Timer/FND Decoupling

`axi_sensor_core` does not instantiate `fnd_controller` or `axi_fnd_core` and has no FND output pins. MicroBlaze software may later read Sensor values and write display values into `axi_fnd_core`.

## Reference RTL Status

The reference Sensor RTL files remain unchanged. No adapted Sensor copy was created in Phase B.

## Verification Status

Sensor Vivado simulation is pending for Phase C.
