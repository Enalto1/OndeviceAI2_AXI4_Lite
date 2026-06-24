#include "periph_timer.h"

#include <string.h>

#include "axi_soc_hw.h"
#include "axi_soc_regs.h"
#include "command_parser.h"
#include "uart_console.h"

static void timer_help(void)
{
    uart_puts("Timer commands:\r\n");
    uart_puts("  timer run | timer stop\r\n");
    uart_puts("  timer down <0|1>\r\n");
    uart_puts("  timer clear\r\n");
    uart_puts("  timer sw\r\n");
    uart_puts("  timer watch\r\n");
    uart_puts("  timer raw\r\n");
    uart_puts("  timer editmode <0|1>\r\n");
    uart_puts("  timer target hour|min|sec [tens|ones]\r\n");
    uart_puts("  timer up | timer downedit\r\n");
    uart_puts("  timer status\r\n");
}

static void timer_write_control_bit(u32 bit, int set)
{
    u32 control = axi_soc_read32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_CONTROL);
    if (set) {
        control |= bit;
    } else {
        control &= ~bit;
    }
    axi_soc_write32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_CONTROL, control);
}

int periph_timer_handle(int argc, char **argv)
{
    u32 value;

    if ((argc < 2) || (strcmp(argv[1], "help") == 0)) {
        timer_help();
        return 0;
    }

    if (strcmp(argv[1], "run") == 0) {
        timer_write_control_bit(TIMER_CONTROL_SW_RUN, 1);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "stop") == 0) {
        timer_write_control_bit(TIMER_CONTROL_SW_RUN, 0);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "down") == 0) {
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("usage: timer down <0|1>");
            return -1;
        }
        timer_write_control_bit(TIMER_CONTROL_SW_DOWN, value != 0U);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "clear") == 0) {
        axi_soc_write32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_COMMAND, TIMER_COMMAND_SW_CLEAR);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "sw") == 0) {
        cmd_print_hex_line("timer.stopwatch", axi_soc_read32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_STOPWATCH_VALUE));
        return 0;
    }
    if (strcmp(argv[1], "watch") == 0) {
        cmd_print_hex_line("timer.watch", axi_soc_read32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_WATCH_VALUE));
        return 0;
    }
    if (strcmp(argv[1], "raw") == 0) {
        cmd_print_hex_line("timer.watch_raw", axi_soc_read32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_WATCH_RAW_DIGITS));
        return 0;
    }
    if (strcmp(argv[1], "editmode") == 0) {
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("usage: timer editmode <0|1>");
            return -1;
        }
        timer_write_control_bit(TIMER_CONTROL_WATCH_SET, value != 0U);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "target") == 0) {
        u32 target;
        u32 control;
        if (argc < 3) {
            cmd_print_error("usage: timer target hour|min|sec [tens|ones]");
            return -1;
        }
        if (strcmp(argv[2], "hour") == 0) {
            target = TIMER_WATCH_TARGET_HOUR;
        } else if (strcmp(argv[2], "min") == 0) {
            target = TIMER_WATCH_TARGET_MIN;
        } else if (strcmp(argv[2], "sec") == 0) {
            target = TIMER_WATCH_TARGET_SEC;
        } else {
            cmd_print_error("bad timer target");
            return -1;
        }
        control = axi_soc_read32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_CONTROL);
        control &= ~(TIMER_CONTROL_WATCH_TARGET_MASK | TIMER_CONTROL_WATCH_DIGIT_SEL);
        control |= ((target << TIMER_CONTROL_WATCH_TARGET_SHIFT) & TIMER_CONTROL_WATCH_TARGET_MASK);
        if ((argc >= 4) && (strcmp(argv[3], "ones") == 0)) {
            control |= TIMER_CONTROL_WATCH_DIGIT_SEL;
        }
        axi_soc_write32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_CONTROL, control);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "up") == 0) {
        axi_soc_write32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_COMMAND, TIMER_COMMAND_WATCH_UP);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "downedit") == 0) {
        axi_soc_write32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_COMMAND, TIMER_COMMAND_WATCH_DOWN);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "status") == 0) {
        cmd_print_hex_line("timer.control", axi_soc_read32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_CONTROL));
        cmd_print_hex_line("timer.status", axi_soc_read32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_STATUS));
        cmd_print_hex_line("timer.version", axi_soc_read32((UINTPTR)AXI_TIMER_BASE, TIMER_REG_VERSION));
        return 0;
    }

    cmd_print_error("unknown timer command");
    return -1;
}
