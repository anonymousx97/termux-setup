#include "../include/sigint.h"
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include "../include/colors.h"
#include "../include/tasks.h"

volatile sig_atomic_t sigint_received = 0;

void sigint_handler(int _) {
    sigint_received = 1;
}

void exit_if_sigint() {
    if (sigint_received) {
        printf(GREEN "Ctrl+c received. Exiting...\n" RESET);
        exit(1);
    }
}

static void _register_handler(void) {
    signal(SIGINT, sigint_handler);
}

__attribute__((constructor)) void register_handler(void) {
    register_init_task(_register_handler);
}
