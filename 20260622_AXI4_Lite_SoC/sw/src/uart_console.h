#ifndef UART_CONSOLE_H
#define UART_CONSOLE_H

#include "xil_types.h"

#define UART_CONSOLE_LINE_MAX 128U

void uart_console_init(void);
void uart_putc(char c);
void uart_puts(const char *s);
void uart_put_hex32(u32 value);
void uart_put_dec32(u32 value);
unsigned int uart_read_line(char *buffer, unsigned int buffer_len);

#endif
