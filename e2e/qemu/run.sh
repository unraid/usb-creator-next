#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/../.." && pwd)

appimage=
dev_image=
artifacts_root="$repo_root/build/e2e-qemu"
cache=${USB_CREATOR_E2E_CACHE:-"$HOME/.cache/unraid-usb-creator-e2e"}

usage() {
    cat <<'EOF'
usage: e2e/qemu/run.sh --appimage PATH --dev-image PATH [--artifacts PATH]
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --appimage) appimage=${2:?}; shift 2 ;;
        --dev-image) dev_image=${2:?}; shift 2 ;;
        --artifacts) artifacts_root=${2:?}; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

test -f "$appimage" || { echo "AppImage not found: $appimage" >&2; exit 2; }
test -f "$dev_image" || { echo "Development image not found: $dev_image" >&2; exit 2; }

for command in cloud-localds curl mcopy mdir mlabel parted qemu-img \
    qemu-system-x86_64 scp sha256sum ssh ssh-keygen; do
    command -v "$command" >/dev/null || {
        echo "Missing required command: $command" >&2
        exit 2
    }
done

mkdir -p "$cache" "$artifacts_root"
cache=$(cd "$cache" && pwd)
artifacts_root=$(cd "$artifacts_root" && pwd)
artifacts="$artifacts_root/run-$(date -u +%Y%m%dT%H%M%SZ)-$$"
mkdir "$artifacts"

base_name=noble-server-cloudimg-amd64.img
base_url="https://cloud-images.ubuntu.com/noble/current/$base_name"
checksums_url="https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"
base_image="$cache/$base_name"

if [[ ! -f "$base_image" ]]; then
    tmp_download="$base_image.partial"
    curl --fail --location --retry 3 --output "$tmp_download" "$base_url"
    curl --fail --location --retry 3 --output "$cache/SHA256SUMS" "$checksums_url"
    expected=$(awk -v file="*$base_name" '$2 == file || $2 == substr(file, 2) {print $1}' "$cache/SHA256SUMS")
    test -n "$expected" || { echo "No checksum found for $base_name" >&2; exit 3; }
    actual=$(sha256sum "$tmp_download" | awk '{print $1}')
    test "$actual" = "$expected" || { echo "Ubuntu image checksum mismatch" >&2; exit 3; }
    mv "$tmp_download" "$base_image"
fi

state=$(mktemp -d "${TMPDIR:-/tmp}/usb-creator-qemu-e2e.XXXXXX")
case "$state" in
    "${TMPDIR:-/tmp}"/usb-creator-qemu-e2e.*) ;;
    *) echo "Unexpected temporary path: $state" >&2; exit 4 ;;
esac

qemu_pid=
cleanup() {
    if [[ -n "$qemu_pid" ]] && kill -0 "$qemu_pid" 2>/dev/null; then
        kill "$qemu_pid" 2>/dev/null || true
        wait "$qemu_pid" 2>/dev/null || true
    fi
    rm -rf "$state"
}
trap cleanup EXIT

overlay="$state/system.qcow2"
target="$state/target.raw"
seed="$state/seed.img"
key="$state/id_ed25519"
qemu-img create -q -f qcow2 -F qcow2 -b "$base_image" "$overlay" 24G
qemu-img create -q -f raw "$target" 2G
ssh-keygen -q -t ed25519 -N '' -f "$key"
public_key=$(<"$key.pub")

cat >"$state/meta-data" <<EOF
instance-id: usb-creator-e2e
local-hostname: usb-creator-e2e
EOF
cat >"$state/user-data" <<EOF
#cloud-config
users:
  - name: e2e
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $public_key
package_update: true
packages:
  - at-spi2-core
  - dbus-x11
  - dosfstools
  - imagemagick
  - libegl1
  - libfuse2t64
  - libgl1
  - libxcb-cursor0
  - openbox
  - python3-dogtail
  - udisks2
  - unzip
  - xvfb
runcmd:
  - [ sh, -c, 'systemctl enable --now udisks2.service || true' ]
  - [ cloud-init-per, once, ready, touch, /var/tmp/usb-creator-e2e-ready ]
EOF

cloud-localds "$seed" "$state/user-data" "$state/meta-data"

ssh_port=${USB_CREATOR_E2E_SSH_PORT:-22222}
if command -v ss >/dev/null && ss -ltn | awk '{print $4}' | grep -q ":$ssh_port$"; then
    echo "SSH port is already in use: $ssh_port" >&2
    exit 4
fi

accel=tcg
cpu=max
if [[ -c /dev/kvm && -r /dev/kvm && -w /dev/kvm ]]; then
    accel=kvm
    cpu=host
fi

qemu-system-x86_64 \
    -machine "q35,accel=$accel" \
    -cpu "$cpu" -smp 2 -m 4096 \
    -display none -serial "file:$artifacts/qemu.log" \
    -drive "if=virtio,format=qcow2,file=$overlay" \
    -drive "if=virtio,format=raw,readonly=on,file=$seed" \
    -drive "if=none,id=e2eusb,format=raw,file=$target" \
    -device qemu-xhci,id=xhci \
    -device usb-storage,bus=xhci.0,drive=e2eusb,removable=on,serial=E2E000000000001 \
    -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:$ssh_port-:22" \
    -device virtio-net-pci,netdev=net0 \
    -no-reboot &
qemu_pid=$!

ssh_opts=(-i "$key" -p "$ssh_port" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5)
scp_opts=(-i "$key" -P "$ssh_port" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5)
for _ in $(seq 1 180); do
    if ssh "${ssh_opts[@]}" e2e@127.0.0.1 'test -e /var/tmp/usb-creator-e2e-ready' 2>/dev/null; then
        break
    fi
    if ! kill -0 "$qemu_pid" 2>/dev/null; then
        echo "QEMU exited before the guest became ready" >&2
        exit 5
    fi
    sleep 5
done
ssh "${ssh_opts[@]}" e2e@127.0.0.1 'test -e /var/tmp/usb-creator-e2e-ready'

ssh "${ssh_opts[@]}" e2e@127.0.0.1 'sudo mkdir -p /opt/usb-creator-e2e && sudo chown e2e:e2e /opt/usb-creator-e2e'
scp "${scp_opts[@]}" "$appimage" e2e@127.0.0.1:/opt/usb-creator-e2e/creator.AppImage
scp "${scp_opts[@]}" "$dev_image" e2e@127.0.0.1:/opt/usb-creator-e2e/unraid-dev-image.zip
scp "${scp_opts[@]}" "$script_dir/guest/drive_creator.py" "$script_dir/guest/run-e2e.sh" e2e@127.0.0.1:/opt/usb-creator-e2e/

ssh "${ssh_opts[@]}" e2e@127.0.0.1 'sudo bash /opt/usb-creator-e2e/run-e2e.sh'
scp -r "${scp_opts[@]}" e2e@127.0.0.1:/opt/usb-creator-e2e/artifacts/. "$artifacts/"
ssh "${ssh_opts[@]}" e2e@127.0.0.1 'sudo poweroff' || true

for _ in $(seq 1 60); do
    kill -0 "$qemu_pid" 2>/dev/null || break
    sleep 1
done
if kill -0 "$qemu_pid" 2>/dev/null; then
    echo "Guest did not power off within 60 seconds" >&2
    exit 6
fi
wait "$qemu_pid" || true
qemu_pid=

cp --sparse=always "$target" "$artifacts/target.raw"
"$script_dir/verify-image.sh" "$artifacts/target.raw" | tee "$artifacts/verification.txt"
echo "E2E evidence: $artifacts"
