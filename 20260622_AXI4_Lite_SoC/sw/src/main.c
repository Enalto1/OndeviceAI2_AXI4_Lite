#include "command_parser.h"
#include "uart_console.h"
#include "xil_cache.h"
#include "xil_printf.h"

int main(void)
{
    char line[UART_CONSOLE_LINE_MAX];

    Xil_ICacheEnable();
    Xil_DCacheEnable();

    uart_console_init();
    command_parser_print_banner();

    while (1) {
        uart_puts("> ");
        (void)uart_read_line(line, sizeof(line));
        (void)command_parser_execute(line);
    }

    return 0;
}
