#!/usr/bin/env bash
# Build an experimental interposer only; never install or activate it here.
set -euo pipefail
: "${ANDROID_NDK_ROOT:?Set ANDROID_NDK_ROOT to the verified extracted Linux NDK}"
output=${1:?usage: build-shim.sh /absolute/path/libwindroid-queue.so}
[[ "$output" == /* ]] || { echo 'Output path must be absolute' >&2; exit 2; }
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
compiler="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android33-clang"
[[ -x "$compiler" ]] || { echo 'Android33 x86_64 compiler is unavailable' >&2; exit 2; }
mkdir -p "$(dirname -- "$output")"
"$compiler" -std=c11 -O1 -g -Wall -Wextra -Werror -shared -fPIC \
    -Wl,-soname,libwindroid-queue.so "$source_dir/queue-shim.c" -ldl -pthread -o "$output"
sha256sum "$output"
