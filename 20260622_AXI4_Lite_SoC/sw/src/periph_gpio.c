#include "periph_gpio.h"

#include <string.h>

#include "axi_soc_hw.h"
#include "axi_soc_regs.h"
#include "command_parser.h"
#include "uart_console.h"

static void gpio_help(void)
{
    uart_puts("GPIO commands:\r\n");
    uart_puts("  gpio out [value]\r\n");
    uart_puts("  gpio set <mask>\r\n");
    uart_puts("  gpio clr <mask>\r\n");
    uart_puts("  gpio toggle <mask>\r\n");
    uart_puts("  gpio in\r\n");
    uart_puts("  gpio edge\r\n");
    uart_puts("  gpio edgeclr <mask>\r\n");
    uart_puts("  gpio status\r\n");
}

int periph_gpio_handle(int argc, char **argv)
{
    u32 value;

    if ((argc < 2) || (strcmp(argv[1], "help") == 0)) {
        gpio_help();
        return 0;
    }

    if (strcmp(argv[1], "out") == 0) {
        if (argc == 2) {
            cmd_print_hex_line("gpio.out", axi_soc_read32((UINTPTR)AXI_GPIO_BASE, GPIO_REG_OUT));
            return 0;
        }
        if (!cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("bad gpio out value");
            return -1;
        }
        axi_soc_write32((UINTPTR)AXI_GPIO_BASE, GPIO_REG_OUT, value & GPIO_LED_MASK);
        cmd_print_ok();
        return 0;
    }

    if ((strcmp(argv[1], "set") == 0) || (strcmp(argv[1], "clr") == 0) || (strcmp(argv[1], "toggle") == 0)) {
        u32 offset = GPIO_REG_SET;
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("bad gpio mask");
            return -1;
        }
        if (strcmp(argv[1], "clr") == 0) {
            offset = GPIO_REG_CLR;
        } else if (strcmp(argv[1], "toggle") == 0) {
            offset = GPIO_REG_TOGGLE;
        }
        axi_soc_write32((UINTPTR)AXI_GPIO_BASE, offset, value & GPIO_LED_MASK);
        cmd_print_ok();
        return 0;
    }

    if (strcmp(argv[1], "in") == 0) {
        value = axi_soc_read32((UINTPTR)AXI_GPIO_BASE, GPIO_REG_IN);
        cmd_print_hex_line("gpio.in", value);
        cmd_print_hex_line("  sw", value & GPIO_IN_SW_MASK);
        cmd_print_hex_line("  btn_deb", (value & GPIO_IN_BTN_DEB_MASK) >> GPIO_IN_BTN_DEB_SHIFT);
        cmd_print_hex_line("  btn_raw", (value & GPIO_IN_BTN_RAW_MASK) >> GPIO_IN_BTN_RAW_SHIFT);
        return 0;
    }

    if (strcmp(argv[1], "edge") == 0) {
        cmd_print_hex_line("gpio.edge", axi_soc_read32((UINTPTR)AXI_GPIO_BASE, GPIO_REG_BTN_EDGE));
        return 0;
    }

    if (strcmp(argv[1], "edgeclr") == 0) {
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("bad edge clear mask");
            return -1;
        }
        axi_soc_write32((UINTPTR)AXI_GPIO_BASE, GPIO_REG_BTN_EDGE_CLR, value & GPIO_BTN_MASK);
        cmd_print_ok();
        return 0;
    }

    if (strcmp(argv[1], "status") == 0) {
        cmd_print_hex_line("gpio.out", axi_soc_read32((UINTPTR)AXI_GPIO_BASE, GPIO_REG_OUT));
        cmd_print_hex_line("gpio.in", axi_soc_read32((UINTPTR)AXI_GPIO_BASE, GPIO_REG_IN));
        cmd_print_hex_line("gpio.edge", axi_soc_read32((UINTPTR)AXI_GPIO_BASE, GPIO_REG_BTN_EDGE));
        cmd_print_hex_line("gpio.version", axi_soc_read32((UINTPTR)AXI_GPIO_BASE, AXI_REG_VERSION));
        return 0;
    }

    cmd_print_error("unknown gpio command");
    return -1;
}
