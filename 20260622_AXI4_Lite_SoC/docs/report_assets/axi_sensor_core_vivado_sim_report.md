# axi_sensor_core Vivado Simulation Report

## Run Summary

| Item | Value |
| --- | --- |
| Peripheral | `axi_sensor_core` |
| Vivado executable used | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat` |
| Vivado version | Vivado v2020.2 (64-bit), SW Build 3064766 |
| Command | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_sensor_core/run_axi_sensor_core_sim.tcl` |
| Working directory | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` |
| Simulation ran | Yes |
| Result | Pass |
| Result file | `sim/vivado/axi_sensor_core/axi_sensor_core_sim_result.txt` |
| Result file contents | `PASS tests_passed=17 errors=0` |
| Testbench pass marker | `[TB PASS] axi_sensor_core directed tests passed (17 tests)` |

## Compiled Sources

The Sensor simulation compiled only the Sensor reference RTL, the Sensor AXI wrapper, and the Sensor testbench:

```text
axi_project_unique_sources/sources/sr04.v
axi_project_unique_sources/sources/dht11.v
rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v
sim/vivado/axi_sensor_core/tb_axi_sensor_core.sv
```

It did not compile GPIO, FND, Timer, SPI, I2C, UVM, MicroBlaze software, or Vivado block-design files.

## Directed Test Summary

| ID | Test | Result |
| --- | --- | --- |
| 1 | reset behavior | Pass |
| 2 | `CONTROL` write/read | Pass |
| 3 | `CONTROL` WSTRB | Pass |
| 4 | `COMMAND` reads zero | Pass |
| 5 | `COMMAND` WSTRB | Pass |
| 6 | `sr04_start` pulse only when `sr04_enable=1` | Pass |
| 7 | `sr04_start` ignored when `sr04_enable=0` | Pass |
| 8 | `sr04_trig_o` activity after start | Pass |
| 9 | simple SR04 echo response produces distance | Pass |
| 10 | `dht_start` pulse only when `dht_enable=1` | Pass |
| 11 | `dht_start` ignored when `dht_enable=0` | Pass |
| 12 | `dht11_io` start-line sanity | Pass |
| 13 | `DHT_VALUE` readback preserves reserved bits | Pass |
| 14 | `STATUS` readback | Pass |
| 15 | `VERSION` read and read-only protection | Pass |
| 16 | reserved offset behavior | Pass |
| 17 | Sensor/FND decoupling compile check | Pass |

The DHT11 check is intentionally limited to command/start-line/status sanity. Full DHT11 response-frame modeling remains future verification work.

## Logs

| Log | Path |
| --- | --- |
| Vivado batch log | `sim/vivado/axi_sensor_core/logs/axi_sensor_core_sim_20260622_190239_vivado.log` |
| xsim log | `sim/vivado/axi_sensor_core/logs/axi_sensor_core_sim_20260622_190239_xsim.log` |

## Warnings And Errors

The post-run log scan found no `ERROR:`, `CRITICAL WARNING`, `WARNING:`, `[CHECK FAIL]`, or `[TB FAIL]` entries in the preserved Vivado/xsim logs. The logs contain the expected Vivado version line and `[TB PASS]` marker.

## Fixes Made

No RTL fixes, testbench fixes, or Tcl fixes were required after running the Sensor simulation. The reference `sr04.v` and `dht11.v` files remained unchanged.

## Evidence Hashes

| File | SHA-256 |
| --- | --- |
| `axi_project_unique_sources/sources/sr04.v` | `8764D48EB2FF173794A72F441C5CFD38666887C8549DC7CC93610B08B0F6597E` |
| `axi_project_unique_sources/sources/dht11.v` | `8FA4E07DDD74477BC7F67C8D67186C3CAB15BC5B8A62683695ECB9AE6D61A75D` |
| `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v` | `B412389E438A09C39D3BAAB6EEFDFB38F38F67D38A69311BC86988D05E601B8C` |
| `sim/vivado/axi_sensor_core/tb_axi_sensor_core.sv` | `C7E3F45DBD5E941E484E8AF3D6EE13EB2913B478D71CC3410695C97905D30F7C` |
| `sim/vivado/axi_sensor_core/run_axi_sensor_core_sim.tcl` | `99B82EB1DC473F2F156AC014C72812751C7E1A04E6A8DDFD3045C6FD1BA0E1A8` |

## Next Step

Because Sensor passed basic Vivado 2020.2 simulation, the next safe milestone is the SPI specification package. SPI RTL implementation is intentionally deferred until after that specification is reviewed.