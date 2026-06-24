#include "command_parser.h"

#include <ctype.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "axi_soc_hw.h"
#include "axi_soc_regs.h"
#include "periph_fnd.h"
#include "periph_gpio.h"
#include "periph_i2c.h"
#include "periph_sensor.h"
#include "periph_spi.h"
#include "periph_timer.h"
#include "uart_console.h"
#include "xil_printf.h"

#define CMD_MAX_ARGS 12

static void str_to_lower(char *s)
{
    while ((s != 0) && (*s != '\0')) {
        *s = (char)tolower((unsigned char)*s);
        s++;
    }
}

int cmd_parse_u32(const char *text, u32 *value)
{
    char *endp = 0;
    unsigned long parsed;

    if ((text == 0) || (value == 0) || (*text == '\0')) {
        return 0;
    }

    parsed = strtoul(text, &endp, 0);
    if ((endp == text) || (*endp != '\0')) {
        return 0;
    }

    *value = (u32)parsed;
    return 1;
}

void cmd_print_ok(void)
{
    uart_puts("OK\r\n");
}

void cmd_print_error(const char *message)
{
    uart_puts("ERR ");
    uart_puts(message);
    uart_puts("\r\n");
}

void cmd_print_hex_line(const char *label, u32 value)
{
    xil_printf("%s = 0x%x\r\n", label, (unsigned int)value);
}

void cmd_print_dec_line(const char *label, u32 value)
{
    xil_printf("%s = %d\r\n", label, (int)value);
}

static int periph_base_from_name(const char *name, UINTPTR *base)
{
    if ((name == 0) || (base == 0)) {
        return 0;
    }

    if (strcmp(name, "uart") == 0) {
        *base = (UINTPTR)AXI_UARTLITE_BASE;
    } else if (strcmp(name, "gpio") == 0) {
        *base = (UINTPTR)AXI_GPIO_BASE;
    } else if (strcmp(name, "fnd") == 0) {
        *base = (UINTPTR)AXI_FND_BASE;
    } else if (strcmp(name, "timer") == 0) {
        *base = (UINTPTR)AXI_TIMER_BASE;
    } else if (strcmp(name, "sensor") == 0) {
        *base = (UINTPTR)AXI_SENSOR_BASE;
    } else if (strcmp(name, "spi") == 0) {
        *base = (UINTPTR)AXI_SPI_BASE;
    } else if (strcmp(name, "i2c") == 0) {
        *base = (UINTPTR)AXI_I2C_BASE;
    } else {
        return 0;
    }

    return 1;
}

static void print_help(void)
{
    uart_puts("Commands:\r\n");
    uart_puts("  help\r\n");
    uart_puts("  version\r\n");
    uart_puts("  status\r\n");
    uart_puts("  periph list\r\n");
    uart_puts("  reg read <addr> | reg read <periph> <offset>\r\n");
    uart_puts("  reg write <addr> <value> | reg write <periph> <offset> <value>\r\n");
    uart_puts("  gpio|fnd|timer|sensor|spi|i2c help\r\n");
}

static void print_periph_list(void)
{
    cmd_print_hex_line("uart", (u32)AXI_UARTLITE_BASE);
    cmd_print_hex_line("gpio", (u32)AXI_GPIO_BASE);
    cmd_print_hex_line("fnd", (u32)AXI_FND_BASE);
    cmd_print_hex_line("timer", (u32)AXI_TIMER_BASE);
    cmd_print_hex_line("sensor", (u32)AXI_SENSOR_BASE);
    cmd_print_hex_line("spi", (u32)AXI_SPI_BASE);
    cmd_print_hex_line("i2c", (u32)AXI_I2C_BASE);
}

static void print_status(void)
{
    cmd_print_hex_line("gpio.version", axi_soc_read32((UINTPTR)AXI_GPIO_BASE, AXI_REG_VERSION));
    cmd_print_hex_line("fnd.version", axi_soc_read32((UINTPTR)AXI_FND_BASE, FND_REG_VERSION));
    cmd_print_hex_line("timer.version", axi_soc_read32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_VERSION));
    cmd_print_hex_line("sensor.version", axi_soc_read32((UINTPTR)AXI_SENSOR_BASE, SENSOR_REG_VERSION));
    cmd_print_hex_line("spi.version", axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_VERSION));
    cmd_print_hex_line("i2c.version", axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_VERSION));
}

static int handle_reg_command(int argc, char **argv)
{
    UINTPTR base = 0U;
    u32 addr_or_offset = 0U;
    u32 value = 0U;

    if (argc < 3) {
        cmd_print_error("usage: reg read|write <addr> [value] or reg read|write <periph> <offset> [value]");
        return -1;
    }

    if (strcmp(argv[1], "read") == 0) {
        if (argc == 3) {
            if (!cmd_parse_u32(argv[2], &addr_or_offset)) {
                cmd_print_error("bad address");
                return -1;
            }
            value = Xil_In32((UINTPTR)addr_or_offset);
            cmd_print_hex_line("read", value);
            return 0;
        }

        if ((argc == 4) && periph_base_from_name(argv[2], &base) && cmd_parse_u32(argv[3], &addr_or_offset)) {
            value = axi_soc_read32(base, addr_or_offset);
            cmd_print_hex_line("read", value);
            return 0;
        }
    }

    if (strcmp(argv[1], "write") == 0) {
        if (argc == 4) {
            if (!cmd_parse_u32(argv[2], &addr_or_offset) || !cmd_parse_u32(argv[3], &value)) {
                cmd_print_error("bad write argument");
                return -1;
            }
            Xil_Out32((UINTPTR)addr_or_offset, value);
            cmd_print_ok();
            return 0;
        }

        if ((argc == 5) && periph_base_from_name(argv[2], &base) && cmd_parse_u32(argv[3], &addr_or_offset) &&
            cmd_parse_u32(argv[4], &value)) {
            axi_soc_write32(base, addr_or_offset, value);
            cmd_print_ok();
            return 0;
        }
    }

    cmd_print_error("bad reg command");
    return -1;
}

void command_parser_print_banner(void)
{
    uart_puts("MicroBlaze AXI4-Lite SoC UART console\r\n");
    uart_puts("Software: " AXI_SOC_SW_VERSION "\r\n");
    uart_puts("Reset input: external active-low PMOD JA4/G2 with pullup\r\n");
    uart_puts("Type 'help' for commands.\r\n");
}

int command_parser_execute(char *line)
{
    char *argv[CMD_MAX_ARGS];
    int argc = 0;
    char *tok;

    if (line == 0) {
        return -1;
    }

    tok = strtok(line, " \t");
    while ((tok != 0) && (argc < CMD_MAX_ARGS)) {
        str_to_lower(tok);
        argv[argc++] = tok;
        tok = strtok(0, " \t");
    }

    if (argc == 0) {
        return 0;
    }

    if (strcmp(argv[0], "help") == 0) {
        print_help();
        return 0;
    }
    if (strcmp(argv[0], "version") == 0) {
        uart_puts(AXI_SOC_SW_VERSION "\r\n");
        return 0;
    }
    if (strcmp(argv[0], "status") == 0) {
        print_status();
        return 0;
    }
    if ((strcmp(argv[0], "periph") == 0) && (argc >= 2) && (strcmp(argv[1], "list") == 0)) {
        print_periph_list();
        return 0;
    }
    if (strcmp(argv[0], "reg") == 0) {
        return handle_reg_command(argc, argv);
    }
    if (strcmp(argv[0], "gpio") == 0) {
        return periph_gpio_handle(argc, argv);
    }
    if (strcmp(argv[0], "fnd") == 0) {
        return periph_fnd_handle(argc, argv);
    }
    if (strcmp(argv[0], "timer") == 0) {
        return periph_timer_handle(argc, argv);
    }
    if (strcmp(argv[0], "sensor") == 0) {
        return periph_sensor_handle(argc, argv);
    }
    if (strcmp(argv[0], "spi") == 0) {
        return periph_spi_handle(argc, argv);
    }
    if (strcmp(argv[0], "i2c") == 0) {
        return periph_i2c_handle(argc, argv);
    }

    cmd_print_error("unknown command");
    return -1;
}
