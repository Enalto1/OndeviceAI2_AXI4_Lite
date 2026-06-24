#include "periph_fnd.h"

#include <string.h>

#include "axi_soc_hw.h"
#include "axi_soc_regs.h"
#include "command_parser.h"
#include "uart_console.h"

static void fnd_help(void)
{
    uart_puts("FND commands:\r\n");
    uart_puts("  fnd on | fnd off\r\n");
    uart_puts("  fnd control <value>\r\n");
    uart_puts("  fnd mode <0..3> [sel]\r\n");
    uart_puts("  fnd timer <msec> <sec> <min> <hour>\r\n");
    uart_puts("  fnd sensor <distance> <humidity> <temperature>\r\n");
    uart_puts("  fnd output\r\n");
    uart_puts("  fnd status\r\n");
}

static void fnd_set_enable(int enable)
{
    u32 control = axi_soc_read32((UINTPTR)AXI_FND_BASE, FND_REG_CONTROL);
    if (enable) {
        control |= FND_CONTROL_ENABLE;
    } else {
        control &= ~FND_CONTROL_ENABLE;
    }
    axi_soc_write32((UINTPTR)AXI_FND_BASE, FND_REG_CONTROL, control);
}

int periph_fnd_handle(int argc, char **argv)
{
    u32 a, b, c, d;

    if ((argc < 2) || (strcmp(argv[1], "help") == 0)) {
        fnd_help();
        return 0;
    }

    if (strcmp(argv[1], "on") == 0) {
        fnd_set_enable(1);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "off") == 0) {
        fnd_set_enable(0);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "control") == 0) {
        if (argc < 3 || !cmd_parse_u32(argv[2], &a)) {
            cmd_print_error("bad fnd control value");
            return -1;
        }
        axi_soc_write32((UINTPTR)AXI_FND_BASE, FND_REG_CONTROL, a & 0x0FU);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "mode") == 0) {
        u32 control = axi_soc_read32((UINTPTR)AXI_FND_BASE, FND_REG_CONTROL);
        if (argc < 3 || !cmd_parse_u32(argv[2], &a) || (a > 3U)) {
            cmd_print_error("bad fnd mode");
            return -1;
        }
        control &= ~(FND_CONTROL_MODE_MASK | FND_CONTROL_SEL);
        control |= ((a << FND_CONTROL_MODE_SHIFT) & FND_CONTROL_MODE_MASK);
        if (argc >= 4) {
            if (!cmd_parse_u32(argv[3], &b)) {
                cmd_print_error("bad fnd select");
                return -1;
            }
            if (b != 0U) {
                control |= FND_CONTROL_SEL;
            }
        }
        axi_soc_write32((UINTPTR)AXI_FND_BASE, FND_REG_CONTROL, control);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "timer") == 0) {
        if (argc < 6 || !cmd_parse_u32(argv[2], &a) || !cmd_parse_u32(argv[3], &b) ||
            !cmd_parse_u32(argv[4], &c) || !cmd_parse_u32(argv[5], &d)) {
            cmd_print_error("usage: fnd timer <msec> <sec> <min> <hour>");
            return -1;
        }
        axi_soc_write32((UINTPTR)AXI_FND_BASE, FND_REG_TIMER_VALUE, FND_PACK_TIMER_VALUE(a, b, c, d));
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "sensor") == 0) {
        if (argc < 5 || !cmd_parse_u32(argv[2], &a) || !cmd_parse_u32(argv[3], &b) || !cmd_parse_u32(argv[4], &c)) {
            cmd_print_error("usage: fnd sensor <distance> <humidity> <temperature>");
            return -1;
        }
        axi_soc_write32((UINTPTR)AXI_FND_BASE, FND_REG_SENSOR_VALUE, FND_PACK_SENSOR_VALUE(a, b, c));
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "output") == 0) {
        cmd_print_hex_line("fnd.output", axi_soc_read32((UINTPTR)AXI_FND_BASE, FND_REG_OUTPUT));
        return 0;
    }
    if (strcmp(argv[1], "status") == 0) {
        cmd_print_hex_line("fnd.control", axi_soc_read32((UINTPTR)AXI_FND_BASE, FND_REG_CONTROL));
        cmd_print_hex_line("fnd.timer", axi_soc_read32((UINTPTR)AXI_FND_BASE, FND_REG_TIMER_VALUE));
        cmd_print_hex_line("fnd.sensor", axi_soc_read32((UINTPTR)AXI_FND_BASE, FND_REG_SENSOR_VALUE));
        cmd_print_hex_line("fnd.output", axi_soc_read32((UINTPTR)AXI_FND_BASE, FND_REG_OUTPUT));
        cmd_print_hex_line("fnd.version", axi_soc_read32((UINTPTR)AXI_FND_BASE, FND_REG_VERSION));
        return 0;
    }

    cmd_print_error("unknown fnd command");
    return -1;
}
