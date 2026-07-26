#!/bin/bash
# UNRAID: launched by the GOW base image once the Wayland session is up.
set -euo pipefail

echo "Unraid USB Creator (Bigscreen) starting..."

# Drive enumeration goes through lsblk. Without a running udev the /dev/disk/by-*
# symlinks are missing, and the storage step comes up empty with no visible
# error -- so say so loudly rather than leaving someone to guess.
if [ ! -d /dev/disk/by-id ]; then
    echo "WARNING: /dev/disk/by-id is missing. The container is probably not"
    echo "         getting host block devices, so no drives will be listed."
    echo "         See src/unraid/container/README.md."
fi

# Writing a raw device needs root. GOW runs apps as the unprivileged 'retro'
# user, so re-exec under sudo when it is available and we are not already root.
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        exec sudo -E /usr/local/bin/unraid-usb-creator "$@"
    fi
    echo "WARNING: running unprivileged; writing to a USB drive will fail."
fi

exec /usr/local/bin/unraid-usb-creator "$@"
