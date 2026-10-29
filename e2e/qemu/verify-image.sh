#!/usr/bin/env bash
set -euo pipefail

image=${1:?usage: verify-image.sh TARGET_RAW SOURCE_ZIP}
source_zip=${2:?usage: verify-image.sh TARGET_RAW SOURCE_ZIP}
mode=${3:-release}
[[ "$mode" == release || "$mode" == backup ]] || { echo "Unknown verification mode: $mode" >&2; exit 2; }
test -f "$image"
test -f "$source_zip"

for command in mcopy mdir mlabel parted python3 sha256sum; do
    command -v "$command" >/dev/null || {
        echo "Missing required command: $command" >&2
        exit 2
    }
done

# The cross-platform formatter uses modern USB geometry that mtools can reject
# even though Linux and Windows mount the FAT32 volume correctly.
export MTOOLS_SKIP_CHECK=1
export MTOOLS_FAT_COMPATIBILITY=1

read -r partition_start filesystem < <(
    parted -ms "$image" unit B print | awk -F: '$1 == "1" {gsub(/B$/, "", $2); print $2, $5}'
)
case "$partition_start" in
    ''|*[!0-9]*) echo "Could not determine FAT32 partition offset" >&2; exit 3 ;;
esac
test "$filesystem" = "fat32" || {
    echo "Expected partition 1 to be FAT32, got: ${filesystem:-unknown}" >&2
    exit 3
}

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

for path in bzimage bzroot bzfirmware bzmodules changes.txt; do
    expected=$(python3 - "$source_zip" "$path" <<'PY'
from hashlib import sha256
import sys
from zipfile import ZipFile

with ZipFile(sys.argv[1]) as archive:
    print(sha256(archive.read(sys.argv[2])).hexdigest())
PY
    )
    actual=$(sha256sum "$verify_dir/$(basename "$path")" | awk '{print $1}')
    test "$actual" = "$expected" || {
        echo "Target payload hash mismatch: $path" >&2
        exit 6
    }
done

require_single_assignment() {
    local file=$1 key=$2 expected=$3
    local count value
    count=$(awk -F= -v key="$key" '$1 == key {count++} END {print count+0}' "$file")
    value=$(awk -F= -v key="$key" '$1 == key {value=substr($0, index($0, "=")+1)} END {print value}' "$file")
    test "$count" -eq 1 && test "$value" = "$expected" || {
        echo "Expected exactly one effective $key=$expected in $(basename "$file")" >&2
        exit 7
    }
}

if [[ "$mode" == backup ]]; then
    # Read every backed-up file through mtools. A label-only fix must not enable
    # customization, replace server settings, or lose nested plugin files.
    python3 - "$source_zip" "$mtools_image" "$verify_dir/restored-file" <<'PYBACKUP'
from pathlib import Path
import subprocess
import sys
from zipfile import ZipFile

with ZipFile(sys.argv[1]) as archive:
    for entry in archive.infolist():
        if entry.is_dir():
            continue
        destination = Path(sys.argv[3])
        destination.unlink(missing_ok=True)
        subprocess.run(["mcopy", "-n", "-i", sys.argv[2], "::" + entry.filename, str(destination)], check=True)
        if destination.read_bytes() != archive.read(entry):
            raise SystemExit(f"Restored backup differs from source: {entry.filename}")
print("Verified Custom backup: UNRAID filesystem label and every backed-up file preserved byte for byte.")
PYBACKUP
else
    require_single_assignment "$verify_dir/ident.cfg" NAME '"Tower"'
    require_single_assignment "$verify_dir/network.cfg" USE_DHCP '"yes"'
fi

echo "Verified QEMU USB image: FAT32 label, source-matching payload, and Unraid configuration ($mode mode) are correct."
