# Experimental upstream source candidates

These patches target `waydroid/android_hardware_waydroid` commit
`a575cfcc12ab79a122844218f2c6df5bd208cca0`. They are review artifacts, not changes
to installed vendor images or installer inputs. Individual and combined
`git apply --check` checks pass against that exact source; reverse checks also
pass against generated candidate files. The queue-only HAL now compiles and links
with strict undefined-symbol checks and passes isolated Android load-only.
The combined queue/pointer HAL also compiles, strict-links and loads. Queue-only
actual-service nested frame/mouse/keyboard controls pass on November8; seamless
and longer validation remain. See NATIVE-BUILD.md.

`candidate-window-sync.patch` gives only window-creation sync callbacks private
queues and fails explicitly on queue/connection errors. Initialization retains
default-queue dispatch. The isolated native race and scoped interposer provide
mechanism/runtime evidence; they do not validate a rebuilt HAL from this patch.
Full lifecycle, first configure, scaling, capture and disconnect/error tests
remain necessary before shipping an upstream binary.

`candidate-pointer-enter.patch` uses the enter event's coordinates through the
existing motion handler. During the four-vCPU control, the first center click
arrived at0,0; the next click arrived at662,313. The pinned enter handler ignores
sx/sy entirely, whereas motion updates Android pointer position. This supports
the hypothesis but is not runtime proof of the candidate. Pipe readiness,
capture/relative input, scaling and subsurface offsets need validation.

The intended integration is an upstream composer source correction, rather
than automatic installation of diagnostic interposers. No PR, remote build,
paid capacity or image publication has been performed.
