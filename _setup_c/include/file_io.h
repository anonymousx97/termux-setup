#ifndef FILE_IO_H
#define FILE_IO_H
#include <sys/stat.h>

char* build_filepath(const char* dir, const char* filename);

int create_dir_recursive(const char* path);

size_t write_to_file_stream(void* ptr, size_t size, size_t buffer_len, void* stream); 

int write_to_file(const char *filename, const char *text, const char *operation_mode);

int check_write_access(const char *path);

int check_exec_access(const char *path);

int is_file(const char *filepath);

#endif
