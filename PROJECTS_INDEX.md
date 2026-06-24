# Projects Index

The Git root `D:\OndeviceAI2_AXI4_Lite` contains multiple projects and generated tool output. The current MicroBlaze AXI4-Lite SoC project now has its own canonical project root.

## Known Root-Level Entries

| Path | Classification | Handling |
| --- | --- | --- |
| `20260622_AXI4_Lite_SoC/` | Current MicroBlaze AXI4-Lite multi-peripheral SoC project | Canonical project root for all future prompts. Contains `docs/`, `rtl_work/`, `sim/`, `axi_project_unique_sources/`, and deferred `UVM_testbench_ref/`. |
| `20260619_AXI4_Master_Slave/` | Existing separate project | Left unchanged. |
| `ip_repo/` | Unclassified or separate content | Left unchanged. |
| `reports/` | Unclassified or separate content | Left unchanged. |
| `simulation_results/` | Unclassified or separate content | Left unchanged. |
| `.Xil/` | Vivado-generated root clutter | Left at Git root and ignored by `.gitignore`. |

## Current Canonical Project Root

```text
D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC
```

Run future project commands from this folder unless a later prompt explicitly says otherwise.

## Root Vivado Log Archive

Prompt 7.5 moved root-level Vivado-generated log/journal files into:

```text
20260622_AXI4_Lite_SoC/_archive/root_vivado_logs
```

Simulation evidence logs under `20260622_AXI4_Lite_SoC/sim/vivado/*/logs/` remain in place.