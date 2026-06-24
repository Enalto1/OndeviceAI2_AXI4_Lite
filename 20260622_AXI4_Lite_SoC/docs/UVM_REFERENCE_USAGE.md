# UVM Reference Usage

Step 0 inspected the RAM UVM split-file reference at:

```text
D:\OndeviceAI2_AXI4_Lite\UVM_testbench_ref\ram_uvm_split
```

The reference files remain unchanged. Future peripheral UVM environments should follow this structure and style after each peripheral has a stable wrapper and simple RTL simulation.

## Reference File Summary

| Reference file | Role | Reuse pattern for future peripherals |
| --- | --- | --- |
| `ram_if.sv` | Interface with clocking blocks and driver/monitor modports. | Create `<peripheral>_if.sv` with AXI-lite or simplified bus signals plus peripheral pins/status as needed. |
| `ram_seq_item.sv` | Transaction item with randomizable fields and `convert2string`. | Create item fields for AXI address, write/read, write data, read data, strobes/response if modeled. |
| `ram_base_seq.sv` | Base sequence with helper tasks for write/read operations. | Create reusable AXI read/write helper tasks. |
| `ram_wr_rd_seq.sv` | Scenario sequence that performs randomized write/read traffic. | Create `<peripheral>_basic_seq.sv` plus targeted control/status sequences. |
| `ram_driver.sv` | Active driver gets items from sequencer and drives interface clocking block. | Drive AXI-lite transactions according to the wrapper interface model. |
| `ram_monitor.sv` | Observes interface activity and publishes transactions through analysis port. | Monitor AXI writes/reads and relevant peripheral outputs/status. |
| `ram_agent.sv` | Builds sequencer, driver, monitor and connects sequencer to driver. | Keep active agent structure for register-bus driving. |
| `ram_scoreboard.sv` | Reference-model checking and final report. | Mirror expected register values and compare readback/status behavior. |
| `ram_coverage.sv` | Subscriber hook for coverage. | Add covergroups for register offsets, command bits, status transitions, and key modes. |
| `ram_env.sv` | Builds agent, scoreboard, coverage and connects monitor analysis port. | Keep environment wiring style. |
| `ram_base_test.sv` | Base test builds environment and prints topology. | Keep base test with common config and env creation. |
| `ram_basic_test.sv` | Runs one scenario sequence with objections. | Create basic smoke tests per peripheral. |
| `ram_pkg.sv` | Package imports UVM and includes files in dependency order. | Keep package include order explicit and simple. |
| `tb_top.sv` | Instantiates interface and DUT, sets virtual interface through `uvm_config_db`, calls `run_test`. | Instantiate wrapper DUT, reference RTL dependencies, clock/reset, and optional FSDB dumping. |
| `README.md` | Notes compile order and FSDB define. | Each future UVM env should include a README with compile/run instructions and pass/fail criteria. |

## Key Style Observations

- The reference uses one class per file.
- The package includes files in dependency order.
- Driver and monitor get a virtual interface through `uvm_config_db`.
- The agent is active and creates `uvm_sequencer`, driver, and monitor.
- The monitor publishes transactions through a `uvm_analysis_port`.
- Scoreboard and coverage subscribe to observed transactions.
- `tb_top.sv` uses `run_test("ram_basic_test")` and guards FSDB dumping with `FSDB_DUMP`.
- The reference is simple and readable, which is appropriate for one-peripheral environments.

## Proposed First UVM Environment: `axi_gpio_core`

Future folder, not created in Step 0:

```text
uvm\axi_gpio_core_uvm\
  axi_gpio_if.sv
  axi_gpio_seq_item.sv
  axi_gpio_base_seq.sv
  axi_gpio_basic_seq.sv
  axi_gpio_driver.sv
  axi_gpio_monitor.sv
  axi_gpio_agent.sv
  axi_gpio_scoreboard.sv
  axi_gpio_coverage.sv
  axi_gpio_env.sv
  axi_gpio_base_test.sv
  axi_gpio_basic_test.sv
  axi_gpio_pkg.sv
  tb_top.sv
  README.md
```

## Proposed GPIO UVM Responsibilities

| Component | Future responsibility |
| --- | --- |
| `axi_gpio_if.sv` | Model AXI4-Lite pins, LED outputs, switch inputs, button inputs, clock, and reset. |
| `axi_gpio_seq_item.sv` | Represent register read/write transactions and expected read data. |
| `axi_gpio_base_seq.sv` | Provide AXI write/read helper tasks. |
| `axi_gpio_basic_seq.sv` | Exercise reset values, LED writes, switch reads, button reads, and optional edge status. |
| `axi_gpio_driver.sv` | Drive AXI4-Lite transactions using the interface clocking block. |
| `axi_gpio_monitor.sv` | Observe completed AXI transactions and sampled GPIO pins. |
| `axi_gpio_scoreboard.sv` | Track expected LED register state and compare readback/status fields. |
| `axi_gpio_coverage.sv` | Cover register offsets, LED patterns, switch patterns, button states, and edge cases. |
| `axi_gpio_env.sv` | Connect agent monitor to scoreboard and coverage. |
| `axi_gpio_basic_test.sv` | Run the basic GPIO scenario with explicit pass/fail reporting. |
| `tb_top.sv` | Instantiate `axi_gpio_core`, interface, clock/reset, and optional FSDB dumping. |

## UVM Timing In The Overall Flow

UVM should not lead the design. For each peripheral:

1. Write the peripheral spec and register map.
2. Implement the AXI wrapper.
3. Pass simple Vivado 2020.2 simulation.
4. Create the standalone UVM environment.
5. Pass UVM tests and update verification summary.
6. Move to board integration.

## Step 0 Boundary

No UVM environment was created in Step 0. The RAM UVM reference was inspected only to document the structure that future environments should follow.
