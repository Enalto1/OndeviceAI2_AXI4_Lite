# axi_i2c_core Vivado Simulation

## Purpose

This directory contains the focused Vivado 2020.2 behavioral simulation for the first master-only `axi_i2c_core` wrapper.

## Files Compiled

```text
axi_project_unique_sources/sources/i2c_master_core.sv
rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v
sim/vivado/axi_i2c_core/tb_axi_i2c_core.sv
```

`i2c_master_core.sv` and `tb_axi_i2c_core.sv` are compiled as SystemVerilog.

## Files Intentionally Not Compiled

```text
axi_project_unique_sources/sources/i2c_slave_core.sv
GPIO/FND/Timer/Sensor/SPI RTL
UVM files
MicroBlaze software
Vivado block-design files
```

The first wrapper and this first simulation are master-only. `i2c_slave_core.sv` remains optional/reference-only for later slave, board-to-board, or loopback work.

## Run Command

From the canonical project root:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl
```

## Expected Result

The testbench writes:

```text
sim/vivado/axi_i2c_core/axi_i2c_core_sim_result.txt
```

Passing format:

```text
PASS tests_passed=23 errors=0
```

The console should include:

```text
[TB PASS] axi_i2c_core directed tests passed
```

## Pull-Up And Stimulus Model

The testbench models I2C pull-ups with `tri1` SCL/SDA nets. Testbench-side low-drive controls can pull SDA low to model ACK and read-data zero bits.

The first directed simulation intentionally uses simplified ACK/NACK/read-data stimulus:

- Holding SDA low during WRITE_BYTE models ACK.
- Releasing SDA during WRITE_BYTE models NACK.
- Releasing SDA during READ_BYTE returns `RXDATA[7:0]=8'hFF`.
- Holding SDA low during READ_BYTE returns `RXDATA[7:0]=8'h00`.

This verifies wrapper-level command/status/open-drain behavior without overfitting the first simulation to every I2C bit timing edge.

## Simulation Timing

The DUT instance overrides the wrapper parameters for simulation only:

```text
I2C_CLK_HZ = 1000
I2C_BUS_HZ = 250
```

The production RTL defaults remain `100_000_000` and `100_000`.

## Reference RTL Policy

The reference I2C RTL remains unchanged. This simulation compiles `i2c_master_core.sv` directly and does not modify or copy it. `i2c_slave_core.sv` is not compiled.
