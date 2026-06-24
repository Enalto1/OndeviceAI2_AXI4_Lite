# Block Design Next Steps

## Immediate Next Step

Prompt 22: Basys3 XDC pin mapping and constraints preparation.

## Recommended Order

1. Create or import a verified Basys3 XDC baseline.
2. Map `clk_100mhz_i`, `reset_i`, UART, GPIO, FND, Sensor, SPI, and I2C external BD ports to reviewed board pins.
3. Review inout handling for `dht11_io`, `i2c_scl_io`, and `i2c_sda_io` before implementation.
4. Run synthesis and implementation after XDC review.
5. Generate bitstream only after constraints are reviewed.
6. Export hardware/XSA after a successful bitstream step.
7. Create the Vitis workspace and MicroBlaze command-parser software after hardware export.
8. Run the board demo through AXI UART Lite commands.
9. Keep UVM deferred until the board integration path is stable or a separate verification campaign is explicitly started.

## Not Done In Prompt 21

- Exact XDC pin mapping
- Synthesis
- Implementation
- Bitstream
- Hardware export/XSA
- Vitis workspace
- C software
- UVM
- Board demo

