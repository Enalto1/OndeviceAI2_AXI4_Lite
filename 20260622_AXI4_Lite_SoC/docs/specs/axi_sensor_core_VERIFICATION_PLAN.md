# axi_sensor_core Verification Plan

## Scope

This plan defines the focused Vivado 2020.2/xsim behavioral simulation for `axi_sensor_core`. The first simulation is directed, not UVM.

## Goals

- Confirm AXI register map and WSTRB behavior.
- Confirm command registers generate one-clock gated pulses.
- Confirm `sr04` and `dht11` reference modules are instantiated and connected.
- Confirm SR04 trigger and distance readback behavior with a simple echo stimulus.
- Confirm DHT11 start-line sanity and value/status readback without faking full protocol coverage.
- Confirm read-only and reserved registers ignore writes.
- Confirm Sensor remains decoupled from FND.

## Directed Checklist

| ID | Test | Expected result |
| --- | --- | --- |
| 1 | Reset behavior | `CONTROL`, `COMMAND`, values, status reset/read as specified; `VERSION = 32'h0001_0000`. |
| 2 | `CONTROL` write/read | `sr04_enable` and `dht_enable` store and read back; reserved bits read zero. |
| 3 | `CONTROL` WSTRB | Byte 0 updates SR04 enable; byte 1 updates DHT enable; bytes 2/3 ignored. |
| 4 | `COMMAND` read-zero | Writes do not store state; reads return zero. |
| 5 | `COMMAND` WSTRB | Byte 0 controls SR04 start; byte 1 controls DHT start. |
| 6 | SR04 start enabled | `sr04_start_pulse` pulses one clock only when enabled. |
| 7 | SR04 start ignored disabled | No `sr04_start_pulse` when disabled. |
| 8 | SR04 trigger activity | `sr04_trig_o` asserts after a valid start. |
| 9 | SR04 echo response | Simple echo stimulus produces a deterministic or nonzero `SR04_VALUE` if practical. |
| 10 | DHT start enabled | `dht_start_pulse` pulses one clock only when enabled. |
| 11 | DHT start ignored disabled | No `dht_start_pulse` when disabled. |
| 12 | DHT11 start-line sanity | `dht11_io` is driven low during the start sequence if practical. |
| 13 | `DHT_VALUE` readback | Humidity/temperature fields read with reserved bits zero. |
| 14 | `STATUS` readback | Live bits and enable mirrors match wrapper/reused module signals. |
| 15 | `VERSION` read and RO protection | `VERSION` remains `32'h0001_0000`. |
| 16 | Reserved offsets | Reserved offsets read zero and do not disturb state. |
| 17 | Sensor/FND decoupling | Simulation compiles without FND RTL. |

## Runtime Strategy

Use simulation-only hierarchical `defparam` overrides on the reference tick generators if Vivado 2020.2 accepts them. Do not modify `sr04.v` or `dht11.v`.

## DHT11 Protocol Limitation

The full DHT11 response waveform contains bidirectional timing and checksum behavior. If full response modeling is not practical in the first unattended basic simulation, record that limitation and cover start-line, command gating, status, and readback structure instead.

## UVM Policy

UVM remains deferred until all custom AXI4-Lite peripherals are implemented and have basic Vivado simulation results.
