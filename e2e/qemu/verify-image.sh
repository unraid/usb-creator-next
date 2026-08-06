#!/usr/bin/env bash
set -euo pipefail

image=${1:?usage: verify-image.sh TARGET_RAW}
test -f "$image"

for command in parted mdir mcopy mlabel; do
    command -v "$command" >/dev/null || {
        echo "Missing required command: $command" >&2
        exit 2
    }
done

partition_start=$(parted -ms "$image" unit B print | awk -F: '$1 == "1" {gsub(/B$/, "", $2); print $2}')
case "$partition_start" in
    ''|*[!0-9]*) echo "Could not determine FAT32 partition offset" >&2; exit 3 ;;
esac

mtools_image="$image@@$partition_start"
label=$(mlabel -i "$mtools_image" -s :: | sed -E 's/.*Volume label is[[:space:]]+//; s/[[:space:]]+$//')
test "$label" = "UNRAID" || {
    echo "Expected FAT32 label UNRAID, got: $label" >&2
    exit 4
}

verify_dir=$(mktemp -d)
trap 'rm -rf "$verify_dir"' EXIT

for path in bzimage bzroot bzfirmware bzmodules changes.txt config/ident.cfg config/network.cfg; do
    mcopy -n -i "$mtools_image" "::$path" "$verify_dir/$(basename "$path")" >/dev/null
    test -s "$verify_dir/$(basename "$path")" || {
        echo "Expected non-empty target file: $path" >&2
        exit 5
    }
done

grep -q '^NAME="Tower"$' "$verify_dir/ident.cfg"
grep -q '^USE_DHCP="yes"$' "$verify_dir/network.cfg"

echo "Verified QEMU USB image: FAT32 label, release payload, and Unraid configuration are correct."
