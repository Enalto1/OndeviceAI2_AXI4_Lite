# axi_timer_core Vivado Simulation

## Purpose

This folder contains the focused Vivado 2020.2 behavioral simulation for `axi_timer_core`.
The simulation is directed, not UVM, and checks the Timer AXI register map, one-clock command pulses, WSTRB behavior, read-only/reserved protection, stopwatch ticking, watch edit behavior, adapter readback, and Timer/FND decoupling.

## Files Compiled

Reference Timer RTL:

- `axi_project_unique_sources/sources/stopwatch_datapath.v`
- `axi_project_unique_sources/sources/watch_datapath.v`
- `axi_project_unique_sources/sources/watch_fnd_adapter.v`

Wrapper RTL:

- `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v`

Testbench:

- `sim/vivado/axi_timer_core/tb_axi_timer_core.sv`

The simulation intentionally does not compile `fnd_controller.v`, `axi_fnd_core.v`, `top_control_unit.v`, `top_stopwatch_watch.v`, GPIO RTL, Sensor/SPI/I2C RTL, UVM files, MicroBlaze software, or Vivado block designs.

## Run Command

Run from the canonical project root:

```text
cd D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl
```

## Expected Result

The testbench writes:

```text
sim/vivado/axi_timer_core/axi_timer_core_sim_result.txt
```

Expected passing contents:

```text
PASS tests_passed=19 errors=0
```

The console transcript should include:

```text
[TB PASS] axi_timer_core directed tests passed
```

## Fast Tick Strategy

The reused stopwatch and watch datapaths contain internal 100 Hz generators with default `F_COUNT = 100_000_000 / 100`.
At 100 MHz, one default tick takes about 1,000,000 simulation cycles.

This testbench uses simulation-only hierarchical parameter overrides:

```verilog
defparam dut.u_stopwatch_datapath.U_TICK_GEN_100HZ.F_COUNT = 8;
defparam dut.u_watch_datapath.uTICK_GEN_100HZ.F_COUNT = 8;
```

The reference Timer RTL files are not modified, and no adapted Timer copy is created.

## Timer/FND Decoupling

`axi_timer_core` remains decoupled from FND hardware. The Timer simulation does not compile or require `fnd_controller.v` or `axi_fnd_core.v`.
