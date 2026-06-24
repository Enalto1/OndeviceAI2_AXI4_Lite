# Basys3 Reset Revision Guide

Prompt 23 uses an external active-low PMOD reset on JA4/G2. This supersedes the Prompt 22 v1 CPU_RESETN/C12 first-pass plan because Vivado 2020.2 rejected C12 for part `xc7a35tcpg236-1` during the bitstream build.

## Option A: Current Reset On PMOD JA4/G2

This is the current applied reset assignment.

- Top-level reset port: `reset_i`
- Physical signal: external PMOD JA4 signal
- Package pin: G2
- Active level: active-low
- XDC pull-up: enabled
- BD handling: `reset_i` passes through `rstn_inv_0`, then drives `proc_sys_reset_0/ext_reset_in`
- Advantage: all five normal Basys3 buttons remain available for GPIO `btn_i[4:0]`
- External hardware needed: active-low push button from JA4/G2 to GND

Reference snippet:

- `constraints/basys3/reset_options/reset_external_pmod_ja4_g2.xdc`

## Option B: Move Reset To Another External PMOD Button

Use this if final wiring needs reset on a different unused PMOD pin.

Wiring model:

```text
PMOD signal ---- push button ---- GND
PMOD signal has PULLUP true
not pressed = 1
pressed     = 0
reset       = active-low
```

Steps:

1. Pick one unused PMOD pin that does not conflict with Sensor JA, SPI JB, or I2C JC.
2. Edit only the reset section in `constraints/basys3/basys3_axi_soc.xdc`.
3. Use `constraints/basys3/reset_options/reset_external_pmod_template.xdc` as the starting point.
4. Keep `reset_i` active-low at the top level.
5. Keep the BD `rstn_inv_0` inverter unless the Processor System Reset polarity is intentionally redesigned.
6. Rerun the Vivado 2020.2 build or XDC apply validation.

## Option C: CPU_RESETN/C12 Historical Reference

Prompt 22 v1 documented CPU_RESETN/C12, but Prompt 23 implementation proved C12 is invalid for the selected project part. Keep `constraints/basys3/reset_options/reset_cpu_resetn_c12.xdc` as historical context only unless the target part/board mapping is deliberately changed and revalidated.

## Option D: Use A Normal Onboard Button As Reset

This is not recommended for the current design because the five normal buttons are already mapped to GPIO:

- `btn_i[0]`: btnC
- `btn_i[1]`: btnU
- `btn_i[2]`: btnL
- `btn_i[3]`: btnR
- `btn_i[4]`: btnD

Use this option only if the GPIO button feature is reduced or remapped. If selected, update the XDC, reset policy docs, GPIO docs, and any software assumptions that read `btn_i[4:0]`.
