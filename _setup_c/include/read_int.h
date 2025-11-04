#ifndef READ_INT_H
#define READ_INT_H

typedef enum InputStatus{
    SUCCESS,
    ERR_EMPTY_INPUT,
    ERR_INVALID_INPUT,
    NOT_SET
} InputStatus;

typedef struct ReadResult{
    InputStatus status;
    int num;
} ReadResult;

ReadResult read_int();

#endif //read_int.h