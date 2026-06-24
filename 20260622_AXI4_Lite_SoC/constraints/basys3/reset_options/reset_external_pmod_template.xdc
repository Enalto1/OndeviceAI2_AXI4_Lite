# Template only. Do not source/apply this file together with the default C12 reset.
# Purpose: move top-level reset_i to an external active-low PMOD push button later.
#
# Wiring model:
#   PMOD signal ---- push button ---- GND
#   PMOD signal has PULLUP true
#   not pressed = 1
#   pressed     = 0
#   reset       = active-low
#
# Pick one unused PMOD pin that does not conflict with Sensor JA, SPI JB, or I2C JC.
# Then copy the three set_property lines into the reset section of:
#   constraints/basys3/basys3_axi_soc.xdc
# replacing the CPU_RESETN C12 reset section.
#
# Example placeholder, not a final assignment:
# set_property PACKAGE_PIN <UNUSED_PMOD_PIN> [get_ports {reset_i}]
# set_property IOSTANDARD LVCMOS33 [get_ports {reset_i}]
# set_property PULLUP true [get_ports {reset_i}]
