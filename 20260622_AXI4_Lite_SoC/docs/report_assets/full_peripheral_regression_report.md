# Full Peripheral Regression Report

## Run Summary

| Item | Value |
| --- | --- |
| Regression script | `sim/vivado/run_all_peripheral_sims.ps1` |
| Vivado executable used | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat` |
| Vivado version | Vivado v2020.2 (64-bit), SW Build 3064766 |
| Working directory | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` |
| Exact command | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File sim\vivado\run_all_peripheral_sims.ps1` |
| Start time | 2026-06-22 22:34:22 +09:00 |
| End time | 2026-06-22 22:36:26 +09:00 |
| Overall result | PASS |

## Per-Peripheral Results

| Order | Peripheral | Simulation Tcl | Result file | Result contents | Fresh Vivado log | Fresh xsim log |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `axi_gpio_core` | `sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl` | `sim/vivado/axi_gpio_core/axi_gpio_core_sim_result.txt` | `PASS tests_passed=12 errors=0` | `sim/vivado/axi_gpio_core/logs/axi_gpio_core_sim_20260622_223425_vivado.log` | `sim/vivado/axi_gpio_core/logs/axi_gpio_core_sim_20260622_223425_xsim.log` |
| 2 | `axi_fnd_core` | `sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl` | `sim/vivado/axi_fnd_core/axi_fnd_core_sim_result.txt` | `PASS tests_passed=16 errors=0` | `sim/vivado/axi_fnd_core/logs/axi_fnd_core_sim_20260622_223450_vivado.log` | `sim/vivado/axi_fnd_core/logs/axi_fnd_core_sim_20260622_223450_xsim.log` |
| 3 | `axi_timer_core` | `sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl` | `sim/vivado/axi_timer_core/axi_timer_core_sim_result.txt` | `PASS tests_passed=19 errors=0` | `sim/vivado/axi_timer_core/logs/axi_timer_core_sim_20260622_223509_vivado.log` | `sim/vivado/axi_timer_core/logs/axi_timer_core_sim_20260622_223509_xsim.log` |
| 4 | `axi_sensor_core` | `sim/vivado/axi_sensor_core/run_axi_sensor_core_sim.tcl` | `sim/vivado/axi_sensor_core/axi_sensor_core_sim_result.txt` | `PASS tests_passed=17 errors=0` | `sim/vivado/axi_sensor_core/logs/axi_sensor_core_sim_20260622_223529_vivado.log` | `sim/vivado/axi_sensor_core/logs/axi_sensor_core_sim_20260622_223529_xsim.log` |
| 5 | `axi_spi_core` | `sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl` | `sim/vivado/axi_spi_core/axi_spi_core_sim_result.txt` | `PASS tests_passed=20 errors=0` | `sim/vivado/axi_spi_core/logs/axi_spi_core_sim_20260622_223549_vivado.log` | `sim/vivado/axi_spi_core/logs/axi_spi_core_sim_20260622_223549_xsim.log` |
| 6 | `axi_i2c_core` | `sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl` | `sim/vivado/axi_i2c_core/axi_i2c_core_sim_result.txt` | `PASS tests_passed=23 errors=0` | `sim/vivado/axi_i2c_core/logs/axi_i2c_core_sim_20260622_223609_vivado.log` | `sim/vivado/axi_i2c_core/logs/axi_i2c_core_sim_20260622_223609_xsim.log` |

## Regression Script Behavior

The script runs from the canonical project root and invokes each existing focused simulation in this order:

1. GPIO
2. FND
3. Timer
4. Sensor
5. SPI
6. I2C

For each peripheral, the script checks that the Tcl file exists, runs Vivado 2020.2, checks the result file exists, compares the result text to the expected PASS string, and stops immediately on any command failure or result mismatch. The script exits with nonzero status on failure and zero on a complete pass.

## Warnings And Errors

No regression failure, `ERROR:`, `CRITICAL WARNING`, `[CHECK FAIL]`, or `[TB FAIL]` was observed in the fresh run evidence.

The GPIO Vivado log contains two known non-fatal simulator warnings:

- `XSIM 43-3373`: `$value$plusargs` is used as a system task in the GPIO testbench.
- The dynamic SystemVerilog string `result_file` is not traceable for waveform viewing.

These warnings did not affect the directed checks or result file. The remaining fresh logs did not show warnings in the post-run scan.

Vivado also emitted informational path-length notes when creating the per-simulation work projects under `sim/vivado/*/vivado_work`. These are informational and did not block simulation.

## Scope Control

This regression used the existing focused simulation Tcl files. It did not create a Vivado block design, package IP, create MicroBlaze software, create UVM, implement new RTL, or modify reference RTL.

## Conclusion

All six custom AXI4-Lite peripherals have a passing Vivado 2020.2 focused simulation baseline. The project is ready to proceed to local Vivado IP packaging preparation.
