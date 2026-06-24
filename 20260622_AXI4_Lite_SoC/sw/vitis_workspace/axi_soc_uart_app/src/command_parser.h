#ifndef COMMAND_PARSER_H
#define COMMAND_PARSER_H

#include "xil_types.h"

void command_parser_print_banner(void);
int command_parser_execute(char *line);
int cmd_parse_u32(const char *text, u32 *value);
void cmd_print_ok(void);
void cmd_print_error(const char *message);
void cmd_print_hex_line(const char *label, u32 value);
void cmd_print_dec_line(const char *label, u32 value);

#endif
