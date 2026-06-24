# Basys3 Reset Constraint Options

These snippets are reference options for the top-level reset port `reset_i`.

Default first-pass policy:

- Use Basys3 CPU_RESETN on package pin C12.
- CPU_RESETN is active-low.
- Keep all five normal Basys3 buttons available as GPIO `btn_i[4:0]`.
- The active-low board reset is converted inside the block design by `rstn_inv_0` before `proc_sys_reset_0/ext_reset_in`.

Files:

- `reset_cpu_resetn_c12.xdc`: historical CPU_RESETN/C12 snippet from Prompt 22; Prompt 23 proved C12 invalid for the selected part.
- `reset_external_pmod_ja4_g2.xdc`: current applied Prompt 23 external active-low reset on PMOD JA4/G2.
- `reset_external_pmod_template.xdc`: commented template for a future external active-low reset button on another unused PMOD signal.

Do not apply multiple reset snippets at the same time. If reset is moved later, update only the reset section of the main XDC, rerun `vivado/scripts/apply_basys3_xdc.tcl`, and re-check the reset policy docs.

