# axi_i2c_core Vivado Simulation Report

## Run Summary

| Item | Value |
| --- | --- |
| Peripheral | `axi_i2c_core` |
| Vivado executable used | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat` |
| Vivado version | Vivado v2020.2 (64-bit), SW Build 3064766 |
| Command | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl` |
| Working directory | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` |
| Simulation ran | Yes |
| Result | Pass |
| Result file | `sim/vivado/axi_i2c_core/axi_i2c_core_sim_result.txt` |
| Result file contents | `PASS tests_passed=23 errors=0` |
| Testbench pass marker | `[TB PASS] axi_i2c_core directed tests passed (23 tests)` |

## Compiled Sources

The I2C simulation compiled only:

```text
axi_project_unique_sources/sources/i2c_master_core.sv
rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v
sim/vivado/axi_i2c_core/tb_axi_i2c_core.sv
```

`i2c_master_core.sv` and `tb_axi_i2c_core.sv` were analyzed as SystemVerilog by Vivado/xvlog.

The simulation did not compile `i2c_slave_core.sv`, GPIO RTL, FND RTL, Timer RTL, Sensor RTL, SPI RTL, UVM files, MicroBlaze software, or Vivado block-design files.

## Directed Test Summary

| ID | Test | Result |
| --- | --- | --- |
| 1 | reset behavior | Pass |
| 2 | `CONTROL` write/read | Pass |
| 3 | `CONTROL` WSTRB behavior | Pass |
| 4 | `TXDATA` write/read and WSTRB | Pass |
| 5 | `COMMAND` read-zero behavior | Pass |
| 6 | command ignored when disabled | Pass |
| 7 | command pulse when enabled and ready | Pass |
| 8 | command priority | Pass |
| 9 | `COMMAND` WSTRB behavior | Pass |
| 10 | `START` command bus activity | Pass |
| 11 | `STOP` command bus release | Pass |
| 12 | `WRITE_BYTE` with ACK | Pass |
| 13 | `WRITE_BYTE` with NACK | Pass |
| 14 | `READ_BYTE` returning `8'hFF` | Pass |
| 15 | `READ_BYTE` returning `8'h00` | Pass |
| 16 | `done_sticky` and `nack_sticky` clear on accepted command | Pass |
| 17 | command ignored when `cmd_ready=0` | Pass |
| 18 | `BUS_STATUS` readback | Pass |
| 19 | `VERSION` read and read-only protection | Pass |
| 20 | read-only write protection | Pass |
| 21 | reserved offset behavior | Pass |
| 22 | open-drain behavior | Pass |
| 23 | I2C independence compile check | Pass |

## Logs

| Log | Path |
| --- | --- |
| Vivado batch log | `sim/vivado/axi_i2c_core/logs/axi_i2c_core_sim_20260622_221807_vivado.log` |
| xsim log | `sim/vivado/axi_i2c_core/logs/axi_i2c_core_sim_20260622_221807_xsim.log` |

## Warnings And Errors

The post-run log scan found no `ERROR:`, `CRITICAL WARNING`, `WARNING:`, `[CHECK FAIL]`, or `[TB FAIL]` entries in the preserved Vivado/xsim logs. The logs contain the expected Vivado version line, SystemVerilog analysis lines for `i2c_master_core.sv` and `tb_axi_i2c_core.sv`, and the `[TB PASS]` marker.

Vivado emitted an informational path-length note for the on-disk work project. It was not a warning and did not block simulation.

## Testbench Model Notes

The testbench models external I2C pull-ups with `tri1` nets on `i2c_scl_io` and `i2c_sda_io`. The directed ACK/NACK/read stimulus drives SDA low or releases it to high-Z as a simple bus peer model for the first master-only wrapper simulation.

The wrapper instance uses simulation-only parameters `I2C_CLK_HZ=1000` and `I2C_BUS_HZ=250` to keep I2C transactions short in behavioral simulation.

## Fixes Made

No RTL, testbench, or Tcl fixes were required after the first I2C simulation run. `axi_i2c_core.v` was not modified during Prompt 18 debugging because the simulation passed on the first run.

Reference I2C RTL remained unchanged:

- `axi_project_unique_sources/sources/i2c_master_core.sv`
- `axi_project_unique_sources/sources/i2c_slave_core.sv`

`i2c_slave_core.sv` remained optional/reference-only and was not compiled.

## Evidence Hashes

| File | SHA-256 |
| --- | --- |
| `axi_project_unique_sources/sources/i2c_master_core.sv` | `F313E73B3DB2D4AAD7229A0D6472437C3D95B49509C6FB3578607DA9470EA13E` |
| `axi_project_unique_sources/sources/i2c_slave_core.sv` | `1E8FCE47B19801540DCD41AD19285810396E191E5184225AB00155A174BA190A` |
| `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v` | `5C8354B5841AA1CD22153DFBCB5D8650AAF0F2444BF077E5DE6E7715721A192A` |
| `sim/vivado/axi_i2c_core/tb_axi_i2c_core.sv` | `E1412C8BCFCA46A673312F94DF0F7F97C3BEA32FFCE898F7314C7584C9592FF4` |
| `sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl` | `4B4D5E196FFE10C59CC14BCA8BC2DF322587242CAEC971AEB9EF70BFAE2217D6` |

## Next Step

Because I2C passed basic Vivado 2020.2 simulation, the next recommended milestone is Prompt 19: full custom peripheral baseline review and MicroBlaze integration preparation.
