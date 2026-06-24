# axi_spi_core Vivado Simulation Report

## Run Summary

| Item | Value |
| --- | --- |
| Peripheral | `axi_spi_core` |
| Vivado executable used | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat` |
| Vivado version | Vivado v2020.2 (64-bit), SW Build 3064766 |
| Command | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl` |
| Working directory | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` |
| Simulation ran | Yes |
| Result | Pass |
| Result file | `sim/vivado/axi_spi_core/axi_spi_core_sim_result.txt` |
| Result file contents | `PASS tests_passed=20 errors=0` |
| Testbench pass marker | `[TB PASS] axi_spi_core directed tests passed (20 tests)` |

## Compiled Sources

The SPI simulation compiled only:

```text
axi_project_unique_sources/sources/spi_master_byte.sv
rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v
sim/vivado/axi_spi_core/tb_axi_spi_core.sv
```

`spi_master_byte.sv` and `tb_axi_spi_core.sv` were analyzed as SystemVerilog by Vivado/xvlog.

The simulation did not compile `spi_slave_byte.sv`, GPIO RTL, FND RTL, Timer RTL, Sensor RTL, I2C RTL, UVM files, MicroBlaze software, or Vivado block-design files.

## Directed Test Summary

| ID | Test | Result |
| --- | --- | --- |
| 1 | reset behavior | Pass |
| 2 | `CONTROL` write/read | Pass |
| 3 | `CONTROL` WSTRB behavior | Pass |
| 4 | `CLKDIV` write/read and WSTRB | Pass |
| 5 | `TXDATA` write/read and WSTRB | Pass |
| 6 | `COMMAND` read-zero behavior | Pass |
| 7 | start ignored when disabled | Pass |
| 8 | start pulse when enabled and idle | Pass |
| 9 | basic SPI transfer mode 0 | Pass |
| 10 | done sticky clear on new accepted start | Pass |
| 11 | start ignored while busy | Pass |
| 12 | `RXDATA` readback with deterministic MISO | Pass |
| 13 | CPOL idle behavior | Pass |
| 14 | CPHA/mode transfer sanity for modes 0-3 | Pass |
| 15 | `CLKDIV` zero clamp | Pass |
| 16 | `VERSION` read and read-only protection | Pass |
| 17 | read-only write protection | Pass |
| 18 | reserved offset behavior | Pass |
| 19 | `COMMAND` WSTRB behavior | Pass |
| 20 | SPI independence compile check | Pass |

## Logs

| Log | Path |
| --- | --- |
| Vivado batch log | `sim/vivado/axi_spi_core/logs/axi_spi_core_sim_20260622_212929_vivado.log` |
| xsim log | `sim/vivado/axi_spi_core/logs/axi_spi_core_sim_20260622_212929_xsim.log` |

## Warnings And Errors

The post-run log scan found no `ERROR:`, `CRITICAL WARNING`, `WARNING:`, `[CHECK FAIL]`, or `[TB FAIL]` entries in the preserved Vivado/xsim logs. The logs contain the expected Vivado version line, SystemVerilog analysis lines for `spi_master_byte.sv` and `tb_axi_spi_core.sv`, and the `[TB PASS]` marker.

Vivado emitted an informational path-length note for the on-disk work project. It was not a warning and did not block simulation.

## Fixes Made

No RTL, testbench, or Tcl fixes were required after the first SPI simulation run. `axi_spi_core.v` was not modified during Prompt 15 debugging because the simulation passed on the first run.

Reference SPI RTL remained unchanged:

- `axi_project_unique_sources/sources/spi_master_byte.sv`
- `axi_project_unique_sources/sources/spi_slave_byte.sv`

`spi_slave_byte.sv` remained optional/reference-only and was not compiled.

## Evidence Hashes

| File | SHA-256 |
| --- | --- |
| `axi_project_unique_sources/sources/spi_master_byte.sv` | `E0BF78F6B1D8BA68E993933E4B54B9F714E97708481E0986B4BFD0A64C54D459` |
| `axi_project_unique_sources/sources/spi_slave_byte.sv` | `8B6726836607E5353728644D78D96C8B13255479CB6CA44519D07104BFCA2336` |
| `rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v` | `3A388A4B1A279C05351C7AF6F9673713506B6F05B0A99B56E8575D62DF30F697` |
| `sim/vivado/axi_spi_core/tb_axi_spi_core.sv` | `098FF689D93619D5F2CC75A4FEDAFFB76F2D5ECABB73C6D2E5BDE415CBAEF970` |
| `sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl` | `0FBEF7D9C63036A9F7C4D70C2600DDB4C4EAE7A78AF961BAEE835AA77535C197` |

## Next Step

Because SPI passed basic Vivado 2020.2 simulation, the next recommended milestone is Prompt 16: `axi_i2c_core` specification.