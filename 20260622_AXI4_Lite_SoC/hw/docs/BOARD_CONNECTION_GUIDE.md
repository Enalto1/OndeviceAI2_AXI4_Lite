# Board Connection Guide

## Scope

This is an offline Basys3 bring-up guide. The board is not connected during Prompt 25A, so no hardware target detection, programming, or UART observation is claimed here.

## Required Physical Setup

1. Connect the Basys3 USB cable to the PC.
2. Set the Basys3 power switch to ON.
3. If powering from USB, configure JP1 for USB power according to the Basys3 reference manual.
4. Use the same USB cable for JTAG programming and USB UART.
5. If the hardware target is not detected later, install or repair the Digilent/Xilinx cable driver.

## Reset Setup

The project reset is `reset_i`, mapped to PMOD JA4 / G2 as an active-low reset with pull-up behavior in the XDC.

- Released or not connected: logic 1, reset released.
- Connected to GND or button pressed: logic 0, reset active.

Do not hold reset low during UART testing.

## External Device Cautions

- Do not connect a 5V HC-SR04 ECHO output directly to FPGA pins.
- Use level shifting or a voltage divider for SR04 ECHO before connecting it to the Basys3.
- Sensor, SPI, and I2C external devices are optional for the first smoke test.
- I2C devices require proper pull-ups and common ground.
