#include "../include/tasks.h"
#include <stdio.h>
#include <stdlib.h>
#include "../include/callable.h"

static Callable INIT_TASKS[MAX_TASKS];
static int init_task_count = 0;

static Callable EXIT_TASKS[MAX_TASKS];
static int exit_task_count = 0;

void register_init_task(Callable t) {
    if (init_task_count >= MAX_TASKS) {
        fprintf(stderr, "Init tasks limit reached.\n");
        return;
    }
    INIT_TASKS[init_task_count++] = t;
}

void register_exit_task(Callable t) {
    if (exit_task_count >= MAX_TASKS) {
        fprintf(stderr, "Exit tasks limit reached.\n");
        return;
    }
    EXIT_TASKS[exit_task_count++] = t;
}

void run_tasks(const TaskType type) {
    Callable* tasks = NULL;
    int length = 0;

    switch (type) {
        case INIT_TASK:
            tasks = INIT_TASKS;
            length = init_task_count;
            break;
        case EXIT_TASK:
            tasks = EXIT_TASKS;
            length = exit_task_count;
            break;
        default:
            fprintf(stderr, "Unknown task type!\n");
            return;
    }

    for (int i = 0; i < length; i++) {
        tasks[i]();
    }
}