# WSL session transport: lab findings

Checked 2026-11-06 on the dedicated Intel/8 GB lab laptop, WSL 3.0.3,
Windroid kernel 6.18.33.1, guest cap 3 GB. This records an unresolved host/guest
transport failure; it is not a production fix.

## Observed failure

New `wsl.exe` commands intermittently failed with WSAETIMEDOUT while an existing
terminal could still execute commands. Kernel diagnostics captured order-7 page
allocation failures in `vmbus_alloc_ring`/`hvs_probe`, followed by
`UtilAcceptVsock` timeout 110. Total available guest memory alone did not predict
success. The pattern matches [WSL issue 40795](https://github.com/microsoft/WSL/issues/40795).

A WSL shutdown recovered command channels without a Windows reboot. Raising
runtime `vm.compaction_proactiveness` from 20 to 80 and requesting compaction
did not prevent recurrence. Neither setting was persisted. After a later clean
start the value was again 20. Do not repeat that experiment as an established fix.

## Investigation without adding channel pressure

Establish one development terminal before starting Android, then reuse it for
guest diagnostics. The lab used a root Bash terminal with history disabled:

```powershell
wsl -d Windroid -u root -e env HISTFILE=/dev/null bash --noprofile --norc
```

Inside that existing terminal, capture bounded diagnostics to the lab evidence
directory rather than repeatedly launching new WSL clients:

```bash
date -Is
free -m
cat /proc/buddyinfo
cat /proc/sys/vm/compaction_proactiveness
ps -e -o pid,ppid,comm | grep Relay
dmesg | tail -n 100
```

This is an ordinary retained terminal, not a listener, background retry service,
or Codex continuation mechanism. Its tool-session identifier may disappear on
an app/context restart. Do not assume a saved identifier is still usable.
Keep account data out of evidence and do not collect broad Android account logs.

When recovery is necessary, save the checkpoint first, then use `wsl --shutdown`
from PowerShell 7. This stops guest applications; it does not unregister the
distro. Reopen one terminal and start the session normally. Preserve Android
data and the existing verified images.

## Upstream comparison and next hypothesis

Confirmed tags: `linux-msft-wsl-6.18.33.1` and `linux-msft-wsl-6.18.54.1`.
The latter is the stock kernel version advertised by this WSL installation;
the loaded custom Windroid kernel remains the former.

The two tags have the same `drivers/hv/channel.c` blob
(`162d6aeece7b3b6e4c321b07008efac49c253af4`):
[old source](https://github.com/microsoft/WSL2-Linux-Kernel/blob/linux-msft-wsl-6.18.33.1/drivers/hv/channel.c),
[new source](https://github.com/microsoft/WSL2-Linux-Kernel/blob/linux-msft-wsl-6.18.54.1/drivers/hv/channel.c).
The inspected ring-size selection in `net/vmw_vsock/hyperv_transport.c` is also
unchanged. Rebuilding that newer tag alone is not established as a solution.

[WSL PR 41252](https://github.com/microsoft/WSL/pull/41252) merged a timeout for
partially connected process relays. That addresses indefinite relay lifetime;
do not assume the older orphan-relay report diagnoses this machine. A later
healthy snapshot here showed two `Relay(childpid)` processes and no bare Relay.
No relays were killed.

[WSL PR 41690](https://github.com/microsoft/WSL/pull/41690), still open when
checked, proposes smaller explicit listener buffers to reduce allocation order,
with throughput tradeoffs. It is a candidate for separate upstream evaluation,
not a verified/shipped fix. No custom WSL init, kernel patch, or global socket
buffer tuning was installed. Before an experiment, establish the exact changed
code, resource budget, baseline, rollback and a bounded validation workload.

## Latest healthy control

The resumed GApps installer completed actual smoke/integration stages. A
separate start after its stop reached readiness in 83.361 seconds. Android IP
and DNS pings passed twice before and twice after that lifecycle cycle;
ConnectivityService reported validated Ethernet. Settings rendered inside nested
Weston and the installed Windows CLI reported both states RUNNING. These are
short controls, not proof of long-session reliability or seamless graphics.

Evidence remains under lab `evidence/2026-11-06-runtime`, including
`vsock-memory-diagnostics.txt`, `gapps-post-smoke-start.txt`,
`gapps-network-post-smoke-restart.txt`, `post-smoke-connectivity-memory.txt`,
`kernel-tag-comparison.txt` and `installed-cli-running-status.txt`.

On November7, the installed Windows CLI again reported both states RUNNING,
and the live framework ensure returned0. Six bounded awake samples from
08:33:31 through08:38:42 each received2/2 replies for both an IP and a DNS name
(12 successful ping commands). This short sample did not reproduce dropout.
An earlier overnight gap included host sleep and is not continuous-uptime
evidence. No network setting or persistent monitoring service was installed.
Evidence: lab `evidence/integration-2026-11-07/network-awake-samples.jsonl`.
