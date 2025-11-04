#include <curl/curl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include "../include/file_io.h"
#include "../include/tasks.h"

static int curl_initialised = 0;

void init_curl(void) {
    CURLcode res = curl_global_init(CURL_GLOBAL_ALL);
    if (res != CURLE_OK) {
        fprintf(stderr, "curl_global_init failed: %s\n", curl_easy_strerror(res));
        return;
    }
    curl_initialised++;
}

__attribute__((constructor)) void _curl_init(void) {
    register_init_task(init_curl);
}

void cleanup_curl(void) {
    curl_global_cleanup();
    curl_initialised--;
}

__attribute__((constructor)) void _curl_de_init(void) {
    register_exit_task(cleanup_curl);
}

int download_file(const char* url, const char* filename, const char* dir, const char* file_mode) {
    if (create_dir_recursive(dir)) {
        return 1;
    }

    char* path = build_filepath(dir, filename);

    if (path == NULL) {
        return 1;
    }

    CURL* curl = curl_easy_init();

    if (!curl) {
        return 1;
    }

    FILE* fp = fopen(path, file_mode);

    if (!fp) {
        free(path);
        return 1;
    }

    curl_easy_setopt(curl, CURLOPT_URL, url);

    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);

    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_to_file_stream);

    curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);

    curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1L);

    curl_easy_setopt(curl, CURLOPT_VERBOSE, 0L);

    curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1L);

    CURLcode res = curl_easy_perform(curl);

    fclose(fp);
    curl_easy_cleanup(curl);

    if (res != CURLE_OK) {
        return 1;
    } else {
        return 0;
    }
}
