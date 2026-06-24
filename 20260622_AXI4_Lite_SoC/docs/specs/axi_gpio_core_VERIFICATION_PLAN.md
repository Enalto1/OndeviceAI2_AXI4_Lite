# `axi_gpio_core` Verification Plan

This is a planning document only. No Vivado simulation testbench or UVM files are created in Prompt 1.

## Verification Scope

The future verification target is `axi_gpio_core` as an AXI4-Lite slave with LED output, switch input readback, raw synchronized button readback, debounced button readback, button edge flags, and version/reserved register behavior.

## Vivado Simulation Plan

Future simple Vivado 2020.2 simulation should include these directed tests:

| Test | Purpose | Expected pass condition |
| --- | --- | --- |
| 1. Reset test | Apply reset and release it. | `GPIO_OUT == 0`, `BTN_EDGE == 0`, `VERSION == 0x0001_0000`, reserved reads return `0`. |
| 2. `GPIO_OUT` write/read | Write LED patterns through offset `0x00`. | `led_o` follows `GPIO_OUT[15:0]`; readback matches written LED bits; reserved bits read `0`. |
| 3. `GPIO_SET` test | Write set masks to offset `0x08`. | Only mask bits written as `1` become set in `GPIO_OUT`. |
| 4. `GPIO_CLR` test | Write clear masks to offset `0x0C`. | Only mask bits written as `1` become clear in `GPIO_OUT`. |
| 5. `GPIO_TOGGLE` test | Write toggle masks to offset `0x10`. | Only mask bits written as `1` invert in `GPIO_OUT`. |
| 6. `GPIO_IN` switch readback | Drive `sw_i` patterns and wait for synchronization. | `GPIO_IN[15:0]` matches synchronized switch inputs. |
| 7. Button debounce/edge flag test | Drive stable button press long enough for debounce. | Debounced level readback follows the specified implementation path; `BTN_EDGE` latches rising event. |
| 8. `BTN_EDGE_CLR` test | Clear selected edge flags through offset `0x18`. | Written `1` bits clear corresponding flags; other flags remain set. |
| 9. `VERSION` read test | Read offset `0x1C`. | Returns `0x0001_0000`; writes have no effect. |
| 10. Reserved address read/write test | Access offsets `0x20` to `0x3C`. | Reads return `0`; writes do not affect any visible register. |

## Debounce Simulation Notes

- The existing `button_debounce.v` uses `F_COUNT = 100_000_000/1000`.
- At a 100 MHz clock, simulation must hold a button input stable long enough for the debounce sampling and 8-bit history to settle.
- Because `button_debounce.o_btn` is a pulse, not a level, simulation should separately check the final chosen debounced-level implementation.
- If an adapted debounce-level copy is introduced later, the simulation must prove that the adapted copy matches the intended stable-level behavior.

## UVM Plan

Future UVM should follow `D:\OndeviceAI2_AXI4_Lite\UVM_testbench_ref\ram_uvm_split` style.

Planned UVM folder:

```text
uvm\axi_gpio_core_uvm\
```

Planned split files:

```text
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

Required UVM sequences/checks:

| Item | Purpose |
| --- | --- |
| Reset sequence | Check reset values and post-reset stability. |
| Directed register read/write sequence | Check `GPIO_OUT`, `GPIO_IN`, `BTN_EDGE`, and `VERSION`. |
| Set/clear/toggle sequence | Verify command-mask effects on expected LED model. |
| Input read sequence | Drive switch/button pins and compare readback after synchronization/debounce latency. |
| Button edge sequence | Generate button press events and verify latched edge flags. |
| Reserved register sequence | Confirm reserved reads return `0` and writes have no effect. |
| Simple random register access sequence | Randomly access implemented/reserved offsets while preserving scoreboard expectations. |
| Scoreboard expected model | Track LED register, edge flags, version, reserved reads, and input sampling behavior. |
| Register offset coverage | Cover all defined offsets and reserved offset class. |
| LED pattern coverage | Cover all-zero, all-one, walking-one, walking-zero, alternating, and random LED masks. |
| Button edge coverage | Cover each of the five button edge flags and multi-button cases. |

## Board Demo Plan

Future Basys3 board demo through AXI UART Lite should include:

| Demo | UART command example | Expected observation |
| --- | --- | --- |
| LED write | `gpio led 0x00F0` | Basys3 LEDs reflect the written pattern. |
| Switch readback | `gpio read` | Terminal prints synchronized switch value. |
| Button readback | `gpio read` | Terminal prints raw synchronized and debounced button fields. |
| Button edge flag | `gpio edge` | Terminal prints latched edge flags after button press. |
| Button edge clear | `gpio edgeclr 0x1F` | Terminal shows selected edge flags cleared. |
| Version read | `gpio version` | Terminal prints `0x0001_0000`. |

## Pass/Fail Criteria

- All documented registers return expected values.
- `GPIO_OUT`, `GPIO_SET`, `GPIO_CLR`, and `GPIO_TOGGLE` agree with one scoreboard LED model.
- Reserved bits and reserved offsets read as `0`.
- Read-only registers ignore writes.
- Write-only command registers do not require meaningful readback and may return `0`.
- Button edge flags latch until cleared.
- Version remains fixed after attempted writes.
