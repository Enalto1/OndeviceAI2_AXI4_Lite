#include "uart_console.h"

#include "xil_printf.h"

extern char inbyte(void);
extern void outbyte(char c);

void uart_console_init(void)
{
    /* BSP stdin/stdout are expected to point at AXI UART Lite. */
}

void uart_putc(char c)
{
    outbyte(c);
}

void uart_puts(const char *s)
{
    while ((s != 0) && (*s != '\0')) {
        uart_putc(*s++);
    }
}

void uart_put_hex32(u32 value)
{
    xil_printf("0x%x", (unsigned int)value);
}

void uart_put_dec32(u32 value)
{
    xil_printf("%d", (int)value);
}

unsigned int uart_read_line(char *buffer, unsigned int buffer_len)
{
    unsigned int pos = 0U;

    if ((buffer == 0) || (buffer_len == 0U)) {
        return 0U;
    }

    while (1) {
        char c = inbyte();

        if ((c == '\r') || (c == '\n')) {
            uart_puts("\r\n");
            buffer[pos] = '\0';
            return pos;
        }

        if ((c == '\b') || (c == 0x7f)) {
            if (pos > 0U) {
                pos--;
                uart_puts("\b \b");
            }
            continue;
        }

        if ((c >= 0x20) && (c <= 0x7e)) {
            if (pos < (buffer_len - 1U)) {
                buffer[pos++] = c;
                uart_putc(c);
            }
        }
    }
}
