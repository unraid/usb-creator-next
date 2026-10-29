#!/usr/bin/env bash
set -euo pipefail

work=/opt/usb-creator-e2e
artifacts="$work/artifacts"
mkdir -p "$artifacts/screenshots"
export USB_CREATOR_CAPTURE_ID
USB_CREATOR_CAPTURE_ID=$(<"$work/capture-id")
export USB_CREATOR_CAPTURE_PLATFORM=linux

chmod +x "$work/creator.AppImage"
cd "$work"
./creator.AppImage --appimage-extract >/dev/null

export DISPLAY=:99
export NO_AT_BRIDGE=0
export QT_LINUX_ACCESSIBILITY_ALWAYS_ON=1
export QT_ACCESSIBILITY=1
export GTK_MODULES=gail:atk-bridge
export LIBGL_ALWAYS_SOFTWARE=1

dbus-run-session -- bash -euo pipefail <<'SESSION'
gsettings set org.gnome.desktop.interface toolkit-accessibility true
# Creator deliberately switches root processes back to the invoking user's
# standard session-bus path. Cloud images have no graphical login session, so
# bridge that path to this isolated test session before Creator starts.
session_bus=${DBUS_SESSION_BUS_ADDRESS#unix:path=}
session_bus=${session_bus%%,*}
mkdir -p /run/user/1000
if [[ ! -e /run/user/1000/bus && ! -L /run/user/1000/bus ]]; then
  ln -s "$session_bus" /run/user/1000/bus
fi
Xvfb :99 -screen 0 1280x800x24 -nolisten tcp >artifacts/xvfb.log 2>&1 &
xvfb_pid=$!
openbox >artifacts/openbox.log 2>&1 &
openbox_pid=$!
cleanup() {
  status=$?
  if [[ $status -ne 0 ]]; then
    import -window root artifacts/screenshots/failure.png 2>/dev/null || true
    echo "--- Creator log ---" >&2
    cat artifacts/creator.log >&2 2>/dev/null || true
  fi
  kill "${creator_pid:-}" "$openbox_pid" "$xvfb_pid" 2>/dev/null || true
}
trap cleanup EXIT

sleep 2
# The SSH wrapper used sudo only to obtain raw-device access. Avoid making
# Creator reinterpret this headless process as a desktop sudo relaunch and
# replace the working isolated D-Bus address with a nonexistent login bus.
unset SUDO_USER SUDO_UID SUDO_GID
creator_args=(--debug)
if [[ -f /opt/usb-creator-e2e/customize ]]; then
  export USB_CREATOR_CUSTOMIZE=1
fi
driver_args=()
if [[ -f /opt/usb-creator-e2e/unraid-backup.zip ]]; then
  # Use the real Custom/file-picker path, without catalog init_format metadata.
  unset UNRAID_DEV_IMAGE
  printf '{"os_list":[]}\n' > /opt/usb-creator-e2e/empty-catalog.json
  creator_args+=(--qml-file-dialogs --repo /opt/usb-creator-e2e/empty-catalog.json)
  driver_args+=(--custom-backup /opt/usb-creator-e2e/unraid-backup.zip)
elif [[ -f /opt/usb-creator-e2e/ready-image.json ]]; then
  python3 - <<'PYREADY'
import json, pathlib
root=pathlib.Path('/opt/usb-creator-e2e')
meta=json.loads((root/'ready-image.json').read_text())
entry={key:meta[key] for key in ('extract_size','extract_sha256','image_download_size','init_format')}
entry.update(name='Unraid (development image)', description='Ready-to-boot USB image under test',
             url=(root/'ready-image.img.zst').as_uri(), contains_multiple_files=False)
(root/'ready-catalog.json').write_text(json.dumps({'os_list':[entry]}))
PYREADY
  creator_args+=(--repo /opt/usb-creator-e2e/ready-catalog.json)
  export USB_CREATOR_WRITE_TIMEOUT=1800
else
  export UNRAID_DEV_IMAGE=/opt/usb-creator-e2e/unraid-dev-image.zip
fi
/opt/usb-creator-e2e/squashfs-root/AppRun "${creator_args[@]}" >artifacts/creator.log 2>&1 &
creator_pid=$!

python3 /opt/usb-creator-e2e/drive_creator.py \
  --screenshots /opt/usb-creator-e2e/artifacts/screenshots \
  --tree-dump /opt/usb-creator-e2e/artifacts/accessibility-tree.txt \
  --manifest /opt/usb-creator-e2e/artifacts/manifest.jsonl \
  --capture-id "${USB_CREATOR_CAPTURE_ID:?}" \
  --platform "${USB_CREATOR_CAPTURE_PLATFORM:?}" "${driver_args[@]}"

kill "$creator_pid" 2>/dev/null || true
wait "$creator_pid" 2>/dev/null || true
SESSION
