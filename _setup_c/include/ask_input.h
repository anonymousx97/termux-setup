#ifndef ASK_INPUT_H
#define ASK_INPUT_H
#include "callable.h"

typedef struct ArrayResult{
    int code;
    MenuCallable func;
} ArrayResult;


typedef struct AskArray{
    int capacity;
    MenuCallable values[20];
} AskArray;


ArrayResult get_result(struct AskArray *array, int idx);
int ask_and_run(struct AskArray *array, char *menu, char *options);

#endif //ask_input.h
