# axi_sensor_core Software Command Plan

## Scope

This document records planned MicroBlaze UART command names for future software. No MicroBlaze software is implemented in this phase.

## Base Address

| Peripheral | Base |
| --- | --- |
| `axi_sensor_core` | `0x44A3_0000` |

## Planned Commands

| Command | Planned behavior |
| --- | --- |
| `sensor sr04 enable` | Set `CONTROL[0]`. |
| `sensor sr04 disable` | Clear `CONTROL[0]`. |
| `sensor sr04 start` | Write `COMMAND[0] = 1`. |
| `sensor sr04 read` | Read `SR04_VALUE[8:0]` and print distance. |
| `sensor dht enable` | Set `CONTROL[8]`. |
| `sensor dht disable` | Clear `CONTROL[8]`. |
| `sensor dht start` | Write `COMMAND[8] = 1`. |
| `sensor dht read` | Read `DHT_VALUE` and print humidity/temperature. |
| `sensor status` | Read `STATUS` and decode live bits plus enable mirrors. |
| `sensor version` | Read `VERSION`. |

## Register Offsets

| Register | Offset |
| --- | --- |
| `CONTROL` | `0x00` |
| `COMMAND` | `0x04` |
| `SR04_VALUE` | `0x08` |
| `DHT_VALUE` | `0x0C` |
| `STATUS` | `0x10` |
| `VERSION` | `0x1C` |

## Notes

Software should poll `STATUS` and/or delay according to sensor timing before reading final values. Future board-demo software can bridge sensor readings into `axi_fnd_core` display registers, but the Sensor peripheral itself remains FND-independent.
