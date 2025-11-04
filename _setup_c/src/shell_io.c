#include "../include/shell_io.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_CMD_LEN 1024

ShellResult run_cmd(const char* cmd) {
    ShellResult result = {.exit_code = 0};

    char stdout_redirected_cmd[MAX_CMD_LEN] = {0};

    strncpy(stdout_redirected_cmd, cmd, MAX_CMD_LEN - 1);
    stdout_redirected_cmd[MAX_CMD_LEN - 1] = '\0';

    if ((strlen(stdout_redirected_cmd) + strlen(" 2>&1")) < MAX_CMD_LEN) {
        strcat(stdout_redirected_cmd, " 2>&1");
    }

    FILE* fp = popen(cmd, "r");

    if (!fp) {
        perror("subprocess popen failed");
        strncpy(result.output, "subprocess popen failed.\n", MAX_OUTPUT_SIZE - 1);
        result.output[MAX_OUTPUT_SIZE - 1] = '\0';
        return result;
    }

    size_t output_buffer_total = 0;

    char buffer[256];  // read in chunks

    while (fgets(buffer, sizeof(buffer), fp) != NULL) {
        size_t current_len = strlen(buffer);
        // check if there's space in output for new data.
        if (output_buffer_total + current_len < MAX_OUTPUT_SIZE - 1) {
            // append the new data
            strcpy(result.output + output_buffer_total, buffer);
            // increase output index
            output_buffer_total += current_len;
            continue;
        }

        // write EOF
        result.output[output_buffer_total] = '\0';
        break;
    }

    int process_status = pclose(fp);
    result.exit_code = WIFEXITED(process_status) ? WEXITSTATUS(process_status) : -1;
    return result;
}

void clear_term(void) {
    printf("\x1b[2J\x1b[H");
}
