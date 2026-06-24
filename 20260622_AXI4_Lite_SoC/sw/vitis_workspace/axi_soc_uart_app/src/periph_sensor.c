#include "periph_sensor.h"

#include <string.h>

#include "axi_soc_hw.h"
#include "axi_soc_regs.h"
#include "command_parser.h"
#include "uart_console.h"

static void sensor_help(void)
{
    uart_puts("Sensor commands:\r\n");
    uart_puts("  sensor enable sr04|dht|all <0|1>\r\n");
    uart_puts("  sensor sr04 start\r\n");
    uart_puts("  sensor sr04 read\r\n");
    uart_puts("  sensor dht start\r\n");
    uart_puts("  sensor dht read\r\n");
    uart_puts("  sensor status\r\n");
}

static void sensor_set_enable(u32 mask, int enable)
{
    u32 control = axi_soc_read32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_CONTROL);
    if (enable) {
        control |= mask;
    } else {
        control &= ~mask;
    }
    axi_soc_write32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_CONTROL, control);
}

int periph_sensor_handle(int argc, char **argv)
{
    u32 value;

    if ((argc < 2) || (strcmp(argv[1], "help") == 0)) {
        sensor_help();
        return 0;
    }

    if (strcmp(argv[1], "enable") == 0) {
        u32 mask = 0U;
        if (argc < 4 || !cmd_parse_u32(argv[3], &value)) {
            cmd_print_error("usage: sensor enable sr04|dht|all <0|1>");
            return -1;
        }
        if (strcmp(argv[2], "sr04") == 0) {
            mask = SENSOR_CONTROL_SR04_ENABLE;
        } else if (strcmp(argv[2], "dht") == 0) {
            mask = SENSOR_CONTROL_DHT_ENABLE;
        } else if (strcmp(argv[2], "all") == 0) {
            mask = SENSOR_CONTROL_SR04_ENABLE | SENSOR_CONTROL_DHT_ENABLE;
        } else {
            cmd_print_error("bad sensor channel");
            return -1;
        }
        sensor_set_enable(mask, value != 0U);
        cmd_print_ok();
        return 0;
    }

    if (strcmp(argv[1], "sr04") == 0) {
        if ((argc >= 3) && (strcmp(argv[2], "start") == 0)) {
            axi_soc_write32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_COMMAND, SENSOR_COMMAND_SR04_START);
            cmd_print_ok();
            return 0;
        }
        if ((argc >= 3) && (strcmp(argv[2], "read") == 0)) {
            value = axi_soc_read32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_SR04_VALUE) & SENSOR_SR04_DISTANCE_MASK;
            cmd_print_dec_line("sensor.sr04.distance", value);
            return 0;
        }
    }

    if (strcmp(argv[1], "dht") == 0) {
        if ((argc >= 3) && (strcmp(argv[2], "start") == 0)) {
            axi_soc_write32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_COMMAND, SENSOR_COMMAND_DHT_START);
            cmd_print_ok();
            return 0;
        }
        if ((argc >= 3) && (strcmp(argv[2], "read") == 0)) {
            value = axi_soc_read32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_DHT_VALUE);
            cmd_print_dec_line("sensor.dht.humidity", value & SENSOR_DHT_HUMIDITY_MASK);
            cmd_print_dec_line("sensor.dht.temperature", (value & SENSOR_DHT_TEMPERATURE_MASK) >> SENSOR_DHT_TEMPERATURE_SHIFT);
            return 0;
        }
    }

    if (strcmp(argv[1], "status") == 0) {
        cmd_print_hex_line("sensor.control", axi_soc_read32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_CONTROL));
        cmd_print_hex_line("sensor.status", axi_soc_read32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_STATUS));
        cmd_print_hex_line("sensor.sr04", axi_soc_read32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_SR04_VALUE));
        cmd_print_hex_line("sensor.dht", axi_soc_read32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_DHT_VALUE));
        cmd_print_hex_line("sensor.version", axi_soc_read32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_VERSION));
        return 0;
    }

    cmd_print_error("unknown sensor command");
    return -1;
}
