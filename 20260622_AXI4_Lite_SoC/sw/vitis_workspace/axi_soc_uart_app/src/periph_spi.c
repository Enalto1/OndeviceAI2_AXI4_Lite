#include "periph_spi.h"

#include <string.h>

#include "axi_soc_hw.h"
#include "axi_soc_regs.h"
#include "command_parser.h"
#include "uart_console.h"

static void spi_help(void)
{
    uart_puts("SPI commands:\r\n");
    uart_puts("  spi enable <0|1>\r\n");
    uart_puts("  spi mode <0..3>\r\n");
    uart_puts("  spi clkdiv <value>\r\n");
    uart_puts("  spi tx <byte>\r\n");
    uart_puts("  spi xfer <byte>\r\n");
    uart_puts("  spi rx\r\n");
    uart_puts("  spi status\r\n");
}

static int spi_wait_done(void)
{
    u32 i;
    u32 status = axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_STATUS);

    if ((status & SPI_STATUS_ENABLE) == 0U) {
        cmd_print_error("spi disabled");
        return -1;
    }

    for (i = 0U; i < SPI_POLL_TIMEOUT; i++) {
        status = axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_STATUS);
        if ((status & SPI_STATUS_DONE_STICKY) != 0U) {
            return 0;
        }
    }
    cmd_print_error("spi timeout");
    return -1;
}

int periph_spi_handle(int argc, char **argv)
{
    u32 value;

    if ((argc < 2) || (strcmp(argv[1], "help") == 0)) {
        spi_help();
        return 0;
    }

    if (strcmp(argv[1], "enable") == 0) {
        u32 control = axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_CONTROL);
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("usage: spi enable <0|1>");
            return -1;
        }
        if (value != 0U) {
            control |= SPI_CONTROL_ENABLE;
        } else {
            control &= ~SPI_CONTROL_ENABLE;
        }
        axi_soc_write32((UINTPTR)AXI_SPI_BASE, SPI_REG_CONTROL, control);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "mode") == 0) {
        u32 control = axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_CONTROL) & ~(SPI_CONTROL_CPOL | SPI_CONTROL_CPHA);
        if (argc < 3 || !cmd_parse_u32(argv[2], &value) || (value > 3U)) {
            cmd_print_error("usage: spi mode <0..3>");
            return -1;
        }
        if ((value & 0x1U) != 0U) {
            control |= SPI_CONTROL_CPHA;
        }
        if ((value & 0x2U) != 0U) {
            control |= SPI_CONTROL_CPOL;
        }
        axi_soc_write32((UINTPTR)AXI_SPI_BASE, SPI_REG_CONTROL, control);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "clkdiv") == 0) {
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("usage: spi clkdiv <value>");
            return -1;
        }
        axi_soc_write32((UINTPTR)AXI_SPI_BASE, SPI_REG_CLKDIV, value & SPI_CLKDIV_MASK);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "tx") == 0) {
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("usage: spi tx <byte>");
            return -1;
        }
        axi_soc_write32((UINTPTR)AXI_SPI_BASE, SPI_REG_TXDATA, value & SPI_TXDATA_MASK);
        cmd_print_ok();
        return 0;
    }
    if (strcmp(argv[1], "xfer") == 0) {
        if (argc < 3 || !cmd_parse_u32(argv[2], &value)) {
            cmd_print_error("usage: spi xfer <byte>");
            return -1;
        }
        axi_soc_write32((UINTPTR)AXI_SPI_BASE, SPI_REG_TXDATA, value & SPI_TXDATA_MASK);
        axi_soc_write32((UINTPTR)AXI_SPI_BASE, SPI_REG_COMMAND, SPI_COMMAND_START);
        if (spi_wait_done() != 0) {
            return -1;
        }
        cmd_print_hex_line("spi.rx", axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_RXDATA) & SPI_RXDATA_MASK);
        return 0;
    }
    if (strcmp(argv[1], "rx") == 0) {
        cmd_print_hex_line("spi.rx", axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_RXDATA) & SPI_RXDATA_MASK);
        return 0;
    }
    if (strcmp(argv[1], "status") == 0) {
        cmd_print_hex_line("spi.control", axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_CONTROL));
        cmd_print_hex_line("spi.clkdiv", axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_CLKDIV));
        cmd_print_hex_line("spi.status", axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_STATUS));
        cmd_print_hex_line("spi.version", axi_soc_read32((UINTPTR)AXI_SPI_BASE, SPI_REG_VERSION));
        return 0;
    }

    cmd_print_error("unknown spi command");
    return -1;
}

