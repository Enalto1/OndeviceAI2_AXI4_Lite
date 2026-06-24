# `axi_gpio_core` Reuse Notes

This document records the GPIO-related reference RTL inspection and Prompt 2 implementation decision.

## Original Reference File

```text
D:\OndeviceAI2_AXI4_Lite\axi_project_unique_sources\sources\button_debounce.v
```

The original reference file remains unchanged.

## Original Module Declaration

```verilog
module button_debounce(
    input       clk,
    input       rst,
    input       i_btn,
    output      o_btn
);
```

## Original Behavior Summary

- Handles one button input.
- Uses active-high reset.
- Samples `i_btn` through an 8-bit history.
- Internal debounced level is high when all sampled bits are high.
- `o_btn` is a one-clock rising pulse from the internal debounced level.
- The original module does not expose the stable debounced level.

## Prompt 2 Implementation Decision

Prompt 2 resolved the debounced-level readback issue by creating an adapted working copy:

```text
D:\OndeviceAI2_AXI4_Lite\rtl_work\legacy_adapted\button_debounce_level\button_debounce_level.v
```

The adapted module is named `button_debounce_level`:

```verilog
module button_debounce_level(
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn_level,
    output o_btn_pulse
);
```

## Why The Adapted Copy Exists

`axi_gpio_core` requires:

- `GPIO_IN[20:16]`: stable debounced button level readback.
- `BTN_EDGE[4:0]`: latched rising-edge flags.

The reference `button_debounce.v` provides only the pulse behavior. The adapted copy preserves the same sampled debounce concept but exposes both outputs:

- `o_btn_level`: stable debounced level.
- `o_btn_pulse`: one-clock rising pulse equivalent to the original `o_btn` behavior.

## Wrapper Usage

`axi_gpio_core.v` instantiates five explicit debounce helpers:

```text
u_btn_db0
u_btn_db1
u_btn_db2
u_btn_db3
u_btn_db4
```

The wrapper first synchronizes `btn_i[4:0]` into the AXI clock domain, then feeds `btn_raw_sync[4:0]` into the debounce helpers. This path reduces metastability risk before debounce sampling.

## Traceability

| Item | Status |
| --- | --- |
| Original `button_debounce.v` | Reference source, unchanged. |
| Adapted `button_debounce_level.v` | Working RTL copy created in Prompt 2. |
| `axi_gpio_core.v` | Instantiates the adapted module five times explicitly. |
| Simulation/UVM/board verification | Not started in Prompt 2. |

## Optional Legacy GPIO Helper

`INPUT_Merger_sw4.v` remains optional/reference-only. It is not used in the Prompt 2 GPIO RTL implementation.
