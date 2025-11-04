#ifndef SHELL_IO_H
#define SHELL_IO_H

#define MAX_OUTPUT_SIZE 8192 // 8mb max output

typedef struct ShellResult {
    int exit_code;
    char output[MAX_OUTPUT_SIZE];
} ShellResult;

void clear_term(void);

#endif // !SHELL_IO_H
