#include "../include/ask_input.h"
#include <stdio.h>
#include "../include/colors.h"
#include "../include/read_int.h"
#include "../include/shell_io.h"
#include "../include/sigint.h"

ArrayResult get_result(AskArray* array, int idx) {
    idx--;
    ArrayResult result = {.code = -1, .func = NULL};

    if (idx < 0 || idx > array->capacity || array->values[idx] == NULL) {
        return result;
    }

    result.func = array->values[idx];
    result.code = 0;
    return result;
}

int ask_and_run(AskArray* array, char* menu, char* options) {
    clear_term();

    char header[27] = "What would you like to do?";

    printf("%s%s:%s\n%s\n%s\n> ", GREEN, menu, RESET, header, options);

    int max_retries = 3;

    int retries = 0;

    while (retries < max_retries) {
        ReadResult choice;
        choice = read_int();
        switch (choice.status) {
            case ERR_EMPTY_INPUT:
            case NOT_SET:
                clear_term();
                printf("%s%s:%s\n%s\n%s\n%sEnter a num.%s\n> ", GREEN, menu, RESET, header, options, RED, RESET);
                break;

            case ERR_INVALID_INPUT:
               clear_term();
                printf("%s%s:%s\n%s\n%s\n%sInvalid input.%s\n> ", GREEN, menu, RESET, header, options, RED, RESET);
                break;

            case SUCCESS:
                ArrayResult result = get_result(array, choice.num);

                if (result.code == -1) {
                    // printf("%s", result.func);
                    clear_term();
                    printf("%s%s:%s\n%s\n%s\n%sInvalid choice.%s\n> ", GREEN, menu, RESET, header, options, RED, RESET);
                    break;
                }

                result.func(choice.num);
                return 0;
        }
        exit_if_sigint();
        retries++;
    }
    if (retries >= max_retries) {
        printf(RED "\nMax retry limit reached.\n" RESET);
    }
    return 0;
}
