/* Experimental composer-only interposer; not installed by Windroid. */
#define _GNU_SOURCE
#include <android/log.h>
#include <dlfcn.h>
#include <errno.h>
#include <pthread.h>
#include <stdatomic.h>
#include <string.h>

static pthread_once_t once = PTHREAD_ONCE_INIT;
static void *(*create_queue)(void *);
static void (*destroy_queue)(void *);
static int (*roundtrip_queue)(void *, void *);
static int (*original_roundtrip)(void *);
static atomic_flag logged_private = ATOMIC_FLAG_INIT;
static atomic_flag logged_original = ATOMIC_FLAG_INIT;

int wl_display_roundtrip(void *display);

static void resolve_functions(void) {
    /* HAL modules can be RTLD_LOCAL. Do not rely on RTLD_NEXT seeing them.
     * NOLOAD requires an existing module; this shim never starts a HAL. */
    void *module = dlopen("/vendor/lib64/hw/hwcomposer.waydroid.so", RTLD_NOW | RTLD_NOLOAD);
    if (!module) return;
    create_queue = dlsym(module, "wl_display_create_queue");
    destroy_queue = dlsym(module, "wl_event_queue_destroy");
    roundtrip_queue = dlsym(module, "wl_display_roundtrip_queue");
    original_roundtrip = dlsym(module, "wl_display_roundtrip");
    if (original_roundtrip == wl_display_roundtrip) original_roundtrip = NULL;
    /* Keep the module reference for the lifetime of these function pointers. */
}

int wl_display_roundtrip(void *display) {
    if (pthread_once(&once, resolve_functions) || !create_queue ||
        !destroy_queue || !roundtrip_queue || !original_roundtrip) {
        errno = ENOSYS;
        return -1;
    }
    /* Initial registry discovery must dispatch the default queue before the
     * background thread exists. Interpose only the exported window creator,
     * without hard-coded binary addresses or changes to other callers. */
    Dl_info caller;
    const char prefix[] = "_ZN6window6createE";
    int window_creator = 0;
    if (dladdr(__builtin_return_address(0), &caller) && caller.dli_fname && caller.dli_sname) {
        const char *name = strrchr(caller.dli_fname, '/');
        name = name ? name + 1 : caller.dli_fname;
        window_creator = !strcmp(name, "hwcomposer.waydroid.so") &&
            !strncmp(caller.dli_sname, prefix, sizeof(prefix) - 1);
    }
    if (!window_creator) {
        if (!atomic_flag_test_and_set(&logged_original))
            __android_log_print(ANDROID_LOG_INFO, "WindroidQueue", "original queue for initialization/other callers");
        return original_roundtrip(display);
    }
    if (!atomic_flag_test_and_set(&logged_private))
        __android_log_print(ANDROID_LOG_INFO, "WindroidQueue", "private queue for window::create");
    /* The background dispatcher must not consume this call's sync callback. */
    void *queue = create_queue(display);
    if (!queue) { errno = ENOMEM; return -1; }
    int result = roundtrip_queue(display, queue);
    int saved_errno = errno;
    destroy_queue(queue);
    errno = saved_errno;
    return result;
}
