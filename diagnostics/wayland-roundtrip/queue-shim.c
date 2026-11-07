/* Experimental composer-only interposer; not installed by Windroid. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <pthread.h>

static pthread_once_t once = PTHREAD_ONCE_INIT;
static void *(*create_queue)(void *);
static void (*destroy_queue)(void *);
static int (*roundtrip_queue)(void *, void *);

static void resolve_functions(void) {
    /* HAL modules can be RTLD_LOCAL. Do not rely on RTLD_NEXT seeing them.
     * NOLOAD requires an existing module; this shim never starts a HAL. */
    void *module = dlopen("/vendor/lib64/hw/hwcomposer.waydroid.so", RTLD_NOW | RTLD_NOLOAD);
    if (!module) return;
    create_queue = dlsym(module, "wl_display_create_queue");
    destroy_queue = dlsym(module, "wl_event_queue_destroy");
    roundtrip_queue = dlsym(module, "wl_display_roundtrip_queue");
    /* Keep the module reference for the lifetime of these function pointers. */
}

int wl_display_roundtrip(void *display) {
    if (pthread_once(&once, resolve_functions) || !create_queue ||
        !destroy_queue || !roundtrip_queue) {
        errno = ENOSYS;
        return -1;
    }
    /* The background dispatcher must not consume this call's sync callback. */
    void *queue = create_queue(display);
    if (!queue) { errno = ENOMEM; return -1; }
    int result = roundtrip_queue(display, queue);
    int saved_errno = errno;
    destroy_queue(queue);
    errno = saved_errno;
    return result;
}
