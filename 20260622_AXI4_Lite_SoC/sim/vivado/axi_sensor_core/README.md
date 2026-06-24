# axi_sensor_core Vivado Simulation

## Purpose

This folder contains the focused Vivado 2020.2 behavioral simulation for `axi_sensor_core`.
The simulation is directed, not UVM, and checks AXI register behavior, command pulse gating, WSTRB, SR04 trigger/echo/distance behavior, DHT11 start-line sanity, status/version/read-only/reserved behavior, and Sensor/FND decoupling.

## Files Compiled

Reference Sensor RTL:

- `axi_project_unique_sources/sources/sr04.v`
- `axi_project_unique_sources/sources/dht11.v`

Wrapper RTL:

- `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v`

Testbench:

- `sim/vivado/axi_sensor_core/tb_axi_sensor_core.sv`

The simulation intentionally does not compile GPIO, FND, Timer, SPI, I2C, UVM, MicroBlaze software, or block-design files.

## Run Command

Run from the canonical project root:

```text
cd D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_sensor_core/run_axi_sensor_core_sim.tcl
```

## Expected Result

The testbench writes:

```text
sim/vivado/axi_sensor_core/axi_sensor_core_sim_result.txt
```

Expected passing contents:

```text
PASS tests_passed=17 errors=0
```

## Timing Strategy

The testbench uses simulation-only hierarchical parameter overrides:

```verilog
defparam dut.u_sr04.U_TICK_GEN_SR04.F_COUNT = 4;
defparam dut.u_dht11.U_TICK_GEN_US.F_COUNT = 4;
```

Reference Sensor RTL files are not modified.

## DHT11 Limitation

The basic unattended simulation verifies DHT command gating, start pulse behavior, bidirectional start-line sanity, readback structure, and status behavior. It does not claim full DHT11 response protocol/checksum coverage.

## Sensor/FND Decoupling

`axi_sensor_core` remains decoupled from FND hardware. This simulation does not compile or require `fnd_controller.v` or `axi_fnd_core.v`.
