# Basys3 Reset Policy

## Current Reset Source

Prompt 23 changed the system reset constraint from the earlier CPU_RESETN/C12 plan to an external PMOD reset because Vivado 2020.2 rejected C12 for the selected part `xc7a35tcpg236-1` during implementation.

- Top-level reset port: `reset_i`
- Current physical board signal: external PMOD JA4 signal
- Current PACKAGE_PIN: G2
- Board active level: active-low
- XDC pull-up: enabled
- Constraint source: `constraints/basys3/basys3_axi_soc.xdc`
- Applied snippet: `constraints/basys3/reset_options/reset_external_pmod_ja4_g2.xdc`

Wiring model:

```text
JA4/G2 signal ---- push button ---- GND
PULLUP true keeps reset_i high when not pressed
Pressed button drives reset_i low
```

## Why CPU_RESETN/C12 Was Not Kept

Prompt 22 v1 initially selected CPU_RESETN/C12 to preserve the five normal Basys3 buttons for GPIO. During Prompt 23 bitstream build, Vivado reported:

```text
'C12' is not a valid site or package pin name.
```

That made the reset pin assignment a real XDC issue, so the smallest non-conflicting fallback was to keep all GPIO buttons unchanged and move reset to an unused PMOD pin. The C12 reset snippet remains as historical reference only.

The five normal buttons remain available for GPIO:

- `btn_i[0]`: btnC, U18
- `btn_i[1]`: btnU, T18
- `btn_i[2]`: btnL, W19
- `btn_i[3]`: btnR, T17
- `btn_i[4]`: btnD, U17

## Active-Low Handling In The BD

The external reset signal is active-low, while the opened Vivado 2020.2 `proc_sys_reset_0` instance keeps `CONFIG.C_EXT_RESET_HIGH` read-only as active-high.

The BD therefore uses an explicit inverter:

```text
JA4/G2 reset_i, active-low
  -> rstn_inv_0 util_vector_logic NOT
  -> proc_sys_reset_0/ext_reset_in, active-high
  -> mb_reset / peripheral_reset / peripheral_aresetn
```

Final BD facts:

- `reset_i` BD port polarity: `ACTIVE_LOW`
- `proc_sys_reset_0 CONFIG.C_EXT_RESET_HIGH`: `1`
- Inversion used: yes, `rstn_inv_0`
- Top-level wrapper port names changed: no

## How To Revise Reset Later

For future external wiring, reset can still be moved without changing RTL:

1. Edit only the reset section of `constraints/basys3/basys3_axi_soc.xdc`.
2. Keep the external button active-low with `PULLUP true` unless the BD reset topology is intentionally changed.
3. Keep `rstn_inv_0` unless the Processor System Reset polarity is intentionally redesigned.
4. Rerun the bitstream build or the XDC apply validation with Vivado 2020.2.
5. Re-check this file and `docs/integration/BASYS3_RESET_REVISION_GUIDE.md`.

Do not map system reset to `btnC`, `btnU`, `btnL`, `btnR`, or `btnD` unless the GPIO button map is deliberately reduced or revised.
