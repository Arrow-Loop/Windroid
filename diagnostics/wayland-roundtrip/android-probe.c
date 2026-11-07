/* Optional isolated Android client; never calls the HAL's open operation. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int (*dispatch_events)(void *);

static void *reader(void *display) {
    while (dispatch_events(display) >= 0) {}
    return NULL;
}

static void *required_symbol(void *library, const char *name) {
    void *symbol = dlsym(library, name);
    if (!symbol) {
        fprintf(stderr, "%s: %s\n", name, dlerror());
        exit(3);
    }
    return symbol;
}

int main(int argc, char **argv) {
    if ((argc != 2 && argc != 3) || (strcmp(argv[1], "load") && strcmp(argv[1], "shared") &&
                      strcmp(argv[1], "private") && strcmp(argv[1], "preload"))) {
        fprintf(stderr, "usage: android-probe load|shared|private|preload [requests:1..100000]\n");
        return 2;
    }
    char *end = NULL;
    long requests = argc == 3 ? strtol(argv[2], &end, 10) : 200;
    if (requests < 1 || requests > 100000 || (end && *end)) return 2;
    setvbuf(stdout, NULL, _IONBF, 0);
    /* Each process is finite even if the requested roundtrip stalls. */
    alarm(5);
    void *library = dlopen("/vendor/lib64/hw/hwcomposer.waydroid.so", RTLD_NOW | RTLD_LOCAL);
    if (!library) {
        fprintf(stderr, "dlopen: %s\n", dlerror());
        return 3;
    }
    void *(*connect_display)(const char *) = required_symbol(library, "wl_display_connect");
    int (*roundtrip)(void *) = required_symbol(library, "wl_display_roundtrip");
    if (!strcmp(argv[1], "preload"))
        roundtrip = required_symbol(RTLD_DEFAULT, "wl_display_roundtrip");
    int (*roundtrip_queue)(void *, void *) = required_symbol(library, "wl_display_roundtrip_queue");
    void *(*create_queue)(void *) = required_symbol(library, "wl_display_create_queue");
    dispatch_events = required_symbol(library, "wl_display_dispatch");
    Dl_info origin;
    if (!dladdr((void *)roundtrip, &origin)) return 3;
    printf("library=%s mode=%s\n", origin.dli_fname, argv[1]);
    if (!strcmp(argv[1], "load")) return 0;
    void *display = connect_display(NULL);
    if (!display) { fprintf(stderr, "connect failed\n"); return 4; }
    void *queue = !strcmp(argv[1], "private") ? create_queue(display) : NULL;
    if (!strcmp(argv[1], "private") && !queue) return 4;
    pthread_t thread;
    if (pthread_create(&thread, NULL, reader, display)) return 4;
    pthread_detach(thread);
    usleep(50000);
    for (long n = 0; n < requests; n++) {
        int result = queue ? roundtrip_queue(display, queue) : roundtrip(display);
        if (result < 0) { fprintf(stderr, "roundtrip failed\n"); return 5; }
        if (n % (requests > 200 ? 2000 : 20) == 0) printf("roundtrips=%ld\n", n + 1);
    }
    printf("PASS %s %ld roundtrips\n", argv[1], requests);
    /* OS teardown closes this test connection and its blocked reader. */
    _Exit(0);
}
