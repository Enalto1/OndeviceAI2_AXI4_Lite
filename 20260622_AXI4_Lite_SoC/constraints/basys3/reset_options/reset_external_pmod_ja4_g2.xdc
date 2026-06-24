# Prompt 23 applied fallback: external active-low PMOD reset on Basys3 JA4/G2.
# Reason: Vivado 2020.2 rejected CPU_RESETN/C12 for target part xc7a35tcpg236-1.
# Wiring model:
#   JA4/G2 signal ---- push button ---- GND
#   PULLUP true keeps reset_i high when not pressed.
#   Pressed button drives reset_i low; BD rstn_inv_0 converts to active-high Processor System Reset.
set_property PACKAGE_PIN G2 [get_ports {reset_i}]
set_property IOSTANDARD LVCMOS33 [get_ports {reset_i}]
set_property PULLUP true [get_ports {reset_i}]
