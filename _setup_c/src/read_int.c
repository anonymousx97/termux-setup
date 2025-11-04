#include "../include/read_int.h"
#include <ctype.h>
#include <errno.h>
#include <read_int.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include "../include/sigint.h"

#define MAX_INPUT_SIZE 10

void remove_char_inplace(char* str, char to_rm) {
    char* src = str;
    char* dest = str;
    while (*src) {
        if (*src != to_rm) {
            *dest = *src;
            dest++;
        }
        src++;
    }
    *dest = '\0';
}

ReadResult read_int() {
    ReadResult result = {.status = NOT_SET};
    char input_line[MAX_INPUT_SIZE];
    char* endptr;

    if (fgets(input_line, MAX_INPUT_SIZE, stdin) == NULL) {
        exit_if_sigint();
        result.status = ERR_EMPTY_INPUT;
        return result;
    }

    exit_if_sigint();

    remove_char_inplace(input_line, ' ');

    exit_if_sigint();

    if (input_line[0] == '\0' || input_line[0] == '\n') {
        result.status = ERR_EMPTY_INPUT;
        return result;
    }

    errno = 0;
    long num;
    num = strtol(input_line, &endptr, 10);

    if (errno == ERANGE) {
        result.status = ERR_INVALID_INPUT;
        return result;
    }

    if (!isspace((unsigned char)*endptr) && *endptr != '\0') {
        result.status = ERR_INVALID_INPUT;
        return result;
    }

    result.num = num;
    result.status = SUCCESS;
    return result;
}
