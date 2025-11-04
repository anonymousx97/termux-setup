#include "../include/file_io.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

int create_dir_recursive(const char* path) {
    // creates all dirs in a path
    // /abc/xyz/123/mno.txt

    char pathbuffer[1024];

    snprintf(pathbuffer, sizeof(pathbuffer), "%s", path);

    size_t len = strlen(pathbuffer);

    // Empty string
    if (len == 0) {
        printf("mkdir: empty path");
        return -1;
    }

    // remove trailing slash ex: abc/ -> abc
    if (pathbuffer[len - 1] == '/') {
        pathbuffer[len - 1] = '\0';
    }

    char* p = pathbuffer + 1;  // skip leading slash

    while (*p) {
        // loop over the chars till you find /
        if (*p == '/') {
            *p = '\0';  // fake the end of the string here

            // call mkdir with whole string till the fake end
            if (mkdir(pathbuffer, 0755) == -1 && errno != EEXIST) {
                perror("mkdir");
                return -1;
            }

            // dir created/exists, continue to sub dir
            *p = '/';  // restore slash
        }

        p++;  // continues to next char
    }

    // create the last directory
    if (mkdir(pathbuffer, 0755) == -1 && errno != EEXIST) {
        perror("mkdir");
        return -1;
    }

    return 0;
}

char* build_filepath(const char* dir, const char* filename) {
    if (!dir || !filename || filename[0] == '\0') {
        perror("empty parameters.");
        return NULL;  // error on empty filename.
    }

    if (create_dir_recursive(dir) == -1) {
        return NULL;  // error creating dir
    }

    size_t dir_len = strlen(dir);

    int should_join_with_slash = 0;

    if (dir_len > 0 && dir[dir_len - 1] != '/') {
        should_join_with_slash = 1;
    }

    size_t full_path_len = dir_len + strlen(filename) + should_join_with_slash + 1;

    char* path = malloc(full_path_len);

    if (dir_len == 0) {
        snprintf(path, full_path_len, "%s", filename);
    }

    else if (should_join_with_slash) {
        snprintf(path, full_path_len, "%s/%s", dir, filename);
    }

    else {
        snprintf(path, full_path_len, "%s%s", dir, filename);
    }

    return path;
}

size_t write_to_file_stream(void* ptr, size_t size, size_t buffer_len, void* stream) {
    FILE* fp = (FILE*)stream;
    return fwrite(ptr, size, buffer_len, fp);
}

int write_to_file(const char* filename, const char* text, const char* operation_mode) {
    FILE* fp = fopen(filename, operation_mode);

    if (!fp) {
        perror("Failed to open file");
        return -1;
    }

    if (fputs(text, fp) == EOF) {  // it writes here in fputs
        perror("Failed to write to file");
        fclose(fp);
        return -1;
    }

    fclose(fp);
    return 0;
}

int check_write_access(const char* path) {
    return (path && (access(path, W_OK) == 0)) ? 0 : -1;
}

int check_exec_access(const char* path) {
    return (path && (access(path, X_OK) == 0)) ? 0 : -1;
}

int is_file(const char* filename) {
    return (filename && (access(filename, F_OK) == 0)) ? 0 : -1;
}
