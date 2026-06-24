# Default first-pass Basys3 system reset option.
# Top-level port: reset_i
# Physical source: Basys3 CPU_RESETN, active-low, package pin C12
# Keep GPIO buttons btn_i[4:0] on the five normal Basys3 push buttons.

set_property PACKAGE_PIN C12 [get_ports {reset_i}]
set_property IOSTANDARD LVCMOS33 [get_ports {reset_i}]
set_property PULLUP true [get_ports {reset_i}]
