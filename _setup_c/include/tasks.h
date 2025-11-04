#ifndef TASKS_H
#define TASKS_H
#include "callable.h"

#define MAX_TASKS 100

typedef enum TaskType {INIT_TASK, EXIT_TASK} TaskType;

void register_init_task(Callable t);

void register_exit_task(Callable t);

void run_tasks(const TaskType type);

#endif //tasks.h
