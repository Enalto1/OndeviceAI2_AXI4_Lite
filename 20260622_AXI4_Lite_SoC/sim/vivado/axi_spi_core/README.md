# axi_spi_core Vivado Simulation

## Purpose

This directory contains the focused Vivado 2020.2 behavioral simulation for the first master-only `axi_spi_core` wrapper.

## Files Compiled

```text
axi_project_unique_sources/sources/spi_master_byte.sv
rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v
sim/vivado/axi_spi_core/tb_axi_spi_core.sv
```

`spi_master_byte.sv` and `tb_axi_spi_core.sv` are compiled as SystemVerilog.

## Files Intentionally Not Compiled

```text
axi_project_unique_sources/sources/spi_slave_byte.sv
GPIO/FND/Timer/Sensor/I2C RTL
UVM files
MicroBlaze software
Vivado block-design files
```

The first wrapper and this first simulation are master-only. `spi_slave_byte.sv` remains optional/reference-only for later slave or loopback work.

## Run Command

From the canonical project root:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl
```

## Expected Result

The testbench writes:

```text
sim/vivado/axi_spi_core/axi_spi_core_sim_result.txt
```

Passing format:

```text
PASS tests_passed=20 errors=0
```

The console should include:

```text
[TB PASS] axi_spi_core directed tests passed
```

## MISO Strategy

The testbench uses deterministic constant-MISO stimulus. Holding `spi_miso_i=1` should produce `RXDATA[7:0]=8'hFF`; holding `spi_miso_i=0` should produce `RXDATA[7:0]=8'h00`. This avoids overfitting the first wrapper simulation to every CPHA edge detail while still proving MISO sampling and RXDATA readback.

## Reference RTL Policy

The reference SPI RTL remains unchanged. This simulation compiles `spi_master_byte.sv` directly and does not modify or copy it.