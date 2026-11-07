# Bounded standalone protocol client; never attaches to or alters Android.
import ctypes, ctypes.util, threading, time, os, sys
lib = ctypes.CDLL(ctypes.util.find_library('wayland-client'), use_errno=True)
p = ctypes.c_void_p
for name, args, result in (
    ('wl_display_connect', [ctypes.c_char_p], p),
    ('wl_display_dispatch', [p], ctypes.c_int),
    ('wl_display_roundtrip', [p], ctypes.c_int),
    ('wl_display_create_queue', [p], p),
    ('wl_display_roundtrip_queue', [p, p], ctypes.c_int),
):
    fn = getattr(lib, name); fn.argtypes = args; fn.restype = result
mode = sys.argv[1]
display = lib.wl_display_connect(None)
if not display: raise RuntimeError('Cannot connect to test compositor')
queue = lib.wl_display_create_queue(display) if mode == 'private' else None
if mode == 'private' and not queue: raise RuntimeError('Cannot create queue')
def reader():
    while lib.wl_display_dispatch(display) >= 0:
        pass
threading.Thread(target=reader, daemon=True).start()
time.sleep(.05)
print('START', mode, flush=True)
for n in range(200):
    result = lib.wl_display_roundtrip_queue(display, queue) if queue else lib.wl_display_roundtrip(display)
    if result < 0: raise RuntimeError('Protocol roundtrip error')
    if n % 20 == 0: print('roundtrips', n + 1, flush=True)
print('PASS', mode, '200 roundtrips', flush=True)
# The OS closes this isolated probe connection, including the blocked reader.
os._exit(0)