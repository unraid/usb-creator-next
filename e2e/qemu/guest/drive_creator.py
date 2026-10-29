#!/usr/bin/env python3
"""Drive the native Qt UI through AT-SPI and capture the E2E storyboard."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

from dogtail.tree import root


def descendants(node):
    yield node
    try:
        children = list(node.children)
    except Exception:
        # Qt can detach a page or delegate between fetching a node and asking
        # Dogtail for its children. Treat that stale subtree as gone and keep
        # walking the current accessibility tree.
        return
    for child in children:
        yield from descendants(child)


def describe(node) -> str:
    return f"{node.roleName}: {node.name}".strip()


def dump_tree(app, destination: Path) -> None:
    destination.write_text(
        "\n".join("  " * depth + describe(node) for depth, node in walk(app)),
        encoding="utf-8",
    )


def walk(node, depth=0):
    yield depth, node
    try:
        children = list(node.children)
    except Exception:
        return
    for child in children:
        yield from walk(child, depth + 1)


def wait_for_app(timeout=90):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        for app in root.applications():
            normalized = (app.name or "").lower().replace("-", " ")
            if "unraid usb creator" in normalized:
                return app
        time.sleep(0.5)
    raise TimeoutError("Unraid USB Creator did not expose an accessibility tree")


def wait_for(app, text: str, roles=(), timeout=60):
    wanted = text.lower()
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        matches = []
        for node in descendants(app):
            try:
                if (
                    wanted in (node.name or "").lower()
                    and (not roles or node.roleName in roles)
                    and node.showing
                ):
                    matches.append(node)
            except Exception:
                # Qt may retire delegate objects while a page changes. Ignore
                # those defunct AT-SPI nodes and continue with the fresh tree.
                continue
        if matches:
            return matches[0]
        time.sleep(0.5)
    raise TimeoutError(f"Timed out waiting for visible accessibility node containing {text!r}")


def wait_for_unique(app, text: str, roles=(), timeout=60):
    wanted = text.lower()
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        matches = []
        for node in descendants(app):
            try:
                if (
                    wanted in (node.name or "").lower()
                    and (not roles or node.roleName in roles)
                    and node.showing
                ):
                    matches.append(node)
            except Exception:
                continue
        if len(matches) == 1:
            return matches[0]
        if len(matches) > 1:
            raise RuntimeError(f"Expected one visible {text!r} target, found {len(matches)}")
        time.sleep(0.5)
    raise TimeoutError(f"Timed out waiting for one visible accessibility node containing {text!r}")


def click(app, text: str, roles=(), timeout=60):
    node = wait_for(app, text, roles=roles, timeout=timeout)
    node.click()
    return node


def select_custom_backup(app, backup: Path) -> None:
    click(app, "Use custom", roles=("list item",))
    field = wait_for_unique(app, "Enter folder or file path", roles=("text",))
    field.text = str(backup)
    click(app, "Open", roles=("push button", "button"))


def shot(
    output: Path,
    manifest: Path,
    name: str,
    *,
    title: str,
    caption: str,
    role: str,
    capture_id: str,
    platform: str,
    flow: str = "create-unraid-usb",
) -> None:
    # A heading becomes visible before the Qt page transition finishes. Wait
    # for the stable frame so evidence never captures a half-rendered page.
    time.sleep(1)
    destination = output / f"{name}.png"
    frame = next(
        node
        for node in descendants(root)
        if node.roleName == "frame"
        and "unraid usb creator" in (node.name or "").lower()
        and node.showing
    )
    x, y = frame.position
    width, height = frame.size
    subprocess.run(
        [
            "import",
            "-window",
            "root",
            "-crop",
            f"{width}x{height}+{x}+{y}",
            "+repage",
            str(destination),
        ],
        check=True,
        timeout=20,
    )
    digest = hashlib.sha256(destination.read_bytes()).hexdigest()
    with manifest.open("a", encoding="utf-8") as stream:
        stream.write(
            json.dumps(
                {
                    "category": "unraid-os",
                    "publicationKey": f"usb-creator:{platform}:{flow}",
                    "captureId": capture_id,
                    "platform": platform,
                    "flow": flow,
                    "name": name,
                    "frameRole": role,
                    "title": title,
                    "caption": caption,
                    "image": f"screenshots/{destination.name}",
                    "sha256": digest,
                },
                sort_keys=True,
            )
            + "\n"
        )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--screenshots", type=Path, required=True)
    parser.add_argument("--tree-dump", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--capture-id", required=True)
    parser.add_argument("--platform", required=True)
    parser.add_argument("--custom-backup", type=Path)
    args = parser.parse_args()
    args.screenshots.mkdir(parents=True, exist_ok=True)
    flow = "restore-unraid-backup" if args.custom_backup else "create-unraid-usb"

    app = wait_for_app()
    try:
        wait_for(app, "Welcome", roles=("heading",), timeout=120)
        shot(
            args.screenshots,
            args.manifest,
            "00-language-selection",
            title="Choose the Creator language",
            caption="Choose the language that the Unraid USB Creator will use, then continue.",
            role="entry",
            capture_id=args.capture_id,
            platform=args.platform,
            flow=flow,
        )
        click(app, "Next", roles=("push button", "button"))

        wait_for(app, "Choose operating system", roles=("heading",), timeout=120)
        shot(
            args.screenshots,
            args.manifest,
            "01-os-selection",
            title="Choose a boot backup" if args.custom_backup else "Choose the development image",
            caption=("Use custom restores a ZIP backup without release catalog metadata."
                     if args.custom_backup else
                     "The Creator offers the small local Unraid development image for a fast end-to-end write."),
            role="decision",
            capture_id=args.capture_id,
            platform=args.platform,
            flow=flow,
        )

        if args.custom_backup:
            select_custom_backup(app, args.custom_backup)
        else:
            click(app, "Unraid (development image)")
        click(app, "Next", roles=("push button", "button"))

        wait_for(app, "Select your storage device", roles=("heading",))
        target = wait_for_unique(app, "QEMU", roles=("list item",), timeout=90)
        # The host creates exactly one USB target; ready images need more than 2 GB.
        # The unique QEMU device check also works for their metadata-sized target.
        target.click()
        shot(
            args.screenshots,
            args.manifest,
            "02-storage-selection",
            title="Select the disposable USB target",
            caption="The QEMU USB mass-storage device is selected as the write target.",
            role="decision",
            capture_id=args.capture_id,
            platform=args.platform,
            flow=flow,
        )
        click(app, "Next", roles=("push button", "button"))

        if args.custom_backup:
            # Custom restores must skip customization and retain the backup settings.
            wait_for(app, "Write image", roles=("heading",))
        elif os.environ.get("USB_CREATOR_CUSTOMIZE") == "1":
            wait_for(app, "Customisation: Server name", roles=("heading",))
            wait_for_unique(app, "Enter your server name", roles=("text",)).text = "ready-usb-test"
            click(app, "Next", roles=("push button", "button"))
            wait_for(app, "Customisation: Wi", roles=("heading",))
            click(app, "Next", roles=("push button", "button"))
            wait_for(app, "Customisation: Network", roles=("heading",))
            click(app, "Next", roles=("push button", "button"))
        else:
            wait_for(app, "Customisation: Server name", roles=("heading",))
            click(app, "Skip customisation", roles=("push button", "button"))

        wait_for(app, "Write image", roles=("heading",))
        if args.custom_backup:
            wait_for(app, args.custom_backup.name)
        shot(
            args.screenshots,
            args.manifest,
            "03-write-summary",
            title="Review the write",
            caption=("The summary identifies the selected ZIP backup and disposable USB target before erasure."
                     if args.custom_backup else
                     "The summary identifies the development image and disposable QEMU USB target before erasure."),
            role="instruction",
            capture_id=args.capture_id,
            platform=args.platform,
            flow=flow,
        )
        click(app, "Write", roles=("push button", "button"))
        click(app, "I understand, erase and write", roles=("push button", "button"), timeout=15)

        wait_for(app, "Write complete!", roles=("heading",), timeout=int(os.environ.get("USB_CREATOR_WRITE_TIMEOUT", "180")))
        shot(
            args.screenshots,
            args.manifest,
            "04-write-complete",
            title="Confirm the write completed",
            caption=("The Creator reports that the boot backup was restored successfully."
                     if args.custom_backup else
                     "The Creator reports that the Unraid development image was written successfully."),
            role="result",
            capture_id=args.capture_id,
            platform=args.platform,
            flow=flow,
        )
        return 0
    finally:
        dump_tree(app, args.tree_dump)


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"E2E UI driver failed: {error}", file=sys.stderr)
        raise
