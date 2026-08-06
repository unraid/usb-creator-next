#!/usr/bin/env bash
set -euo pipefail

work=/opt/usb-creator-e2e
artifacts="$work/artifacts"
mkdir -p "$artifacts/screenshots"

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
UNRAID_DEV_IMAGE=/opt/usb-creator-e2e/unraid-dev-image.zip \
  /opt/usb-creator-e2e/squashfs-root/AppRun --debug \
  >artifacts/creator.log 2>&1 &
creator_pid=$!

python3 /opt/usb-creator-e2e/drive_creator.py \
  --screenshots /opt/usb-creator-e2e/artifacts/screenshots \
  --tree-dump /opt/usb-creator-e2e/artifacts/accessibility-tree.txt \
  --manifest /opt/usb-creator-e2e/artifacts/manifest.jsonl

kill "$creator_pid" 2>/dev/null || true
wait "$creator_pid" 2>/dev/null || true
SESSION
