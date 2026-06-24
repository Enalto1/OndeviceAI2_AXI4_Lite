#include "periph_i2c.h"

#include <string.h>

#include "axi_soc_hw.h"
#include "axi_soc_regs.h"
#include "command_parser.h"
#include "uart_console.h"

static void i2c_help(void)
{
    uart_puts("I2C commands:\r\n");
    uart_puts("  i2c enable <0|1>\r\n");
    uart_puts("  i2c readack <0|1>\r\n");
    uart_puts("  i2c start\r\n");
    uart_puts("  i2c stop\r\n");
    uart_puts("  i2c write <byte>\r\n");
    uart_puts("  i2c read [ack|nack]\r\n");
    uart_puts("  i2c rx\r\n");
    uart_puts("  i2c status\r\n");
    uart_puts("  i2c bus\r\n");
}

static int i2c_wait_done(void)
{
    u32 i;
    for (i = 0U; i < I2C_POLL_TIMEOUT; i++) {
        u32 status = axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_STATUS);
        if ((status & I2C_STATUS_DONE_STICKY) != 0U) {
            if ((status & I2C_STATUS_NACK_STICKY) != 0U) {
                cmd_print_error("i2c nack");
                return -1;
            }
            return 0;
        }
    }
    cmd_print_error("i2c timeout");
    return -1;
}

static int i2c_issue(u32 command)
{
    u32 status = axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_STATUS);

    if ((status & I2C_STATUS_ENABLE) == 0U) {
        cmd_print_error("i2c disabled");
        return -1;
    }
    if ((status & I2C_STATUS_CMD_READY) == 0U) {
        cmd_print_error("i2c not ready");
        return -1;
    }

    axi_soc_write32((UINTPTR)AXI_I2C_BASE, I2C_REG_COMMAND, command);
    return i2c_wait_done();
}

int periph_i2c_handle(int argc, char **argv)
{
    u32 value;

    if ((argc < 2) || (strcmp(argv[1], "help") == 0)) {
        i2c_help();
        return 0;
    }

    if (strcmp(argv[1], "enable") == 0) {
        u32 control = axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_CONTROL);
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("usage: i2c enable <0|1>");
            return -1;
        }
        if (value != 0U) {
            control |= I2C_CONTROL_ENABLE;
        } else {
            control &= ~I2C_CONTROL_ENABLE;
        }
        axi_soc_write32((UINTPTR)AXI_I2C_BASE, I2C_REG_CONTROL, control);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "readack") == 0) {
        u32 control = axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_CONTROL);
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("usage: i2c readack <0|1>");
            return -1;
        }
        if (value != 0U) {
            control |= I2C_CONTROL_READ_ACK;
        } else {
            control &= ~I2C_CONTROL_READ_ACK;
        }
        axi_soc_write32((UINTPTR)AXI_I2C_BASE, I2C_REG_CONTROL, control);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "start") == 0) {
        if (i2c_issue(I2C_COMMAND_START) != 0) {
            return -1;
        }
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "stop") == 0) {
        if (i2c_issue(I2C_COMMAND_STOP) != 0) {
            return -1;
        }
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "write") == 0) {
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("usage: i2c write <byte>");
            return -1;
        }
        axi_soc_write32((UINTPTR)AXI_I2C_BASE, I2C_REG_TXDATA, value & I2C_TXDATA_MASK);
        if (i2c_issue(I2C_COMMAND_WRITE_BYTE) != 0) {
            return -1;
        }
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "read") == 0) {
        u32 control = axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_CONTROL);
        if ((argc >= 3) && (strcmp(argv[2], "ack") == 0)) {
            control |= I2C_CONTROL_READ_ACK;
        } else if ((argc >= 3) && (strcmp(argv[2], "nack") == 0)) {
            control &= ~I2C_CONTROL_READ_ACK;
        }
        axi_soc_write32((UINTPTR)AXI_I2C_BASE, I2C_REG_CONTROL, control);
        if (i2c_issue(I2C_COMMAND_READ_BYTE) != 0) {
            return -1;
        }
        cmd_print_hex_line("i2c.rx", axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_RXDATA) & I2C_RXDATA_MASK);
        return 0;
    }
    if (strcmp(argv[1], "rx") == 0) {
        cmd_print_hex_line("i2c.rx", axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_RXDATA) & I2C_RXDATA_MASK);
        return 0;
    }
    if (strcmp(argv[1], "status") == 0) {
        cmd_print_hex_line("i2c.control", axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_CONTROL));
        cmd_print_hex_line("i2c.status", axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_STATUS));
        cmd_print_hex_line("i2c.version", axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_VERSION));
        return 0;
    }
    if (strcmp(argv[1], "bus") == 0) {
        cmd_print_hex_line("i2c.bus", axi_soc_read32((UINTPTR)AXI_I2C_BASE, I2C_REG_BUS_STATUS));
        return 0;
    }

    cmd_print_error("unknown i2c command");
    return -1;
}


