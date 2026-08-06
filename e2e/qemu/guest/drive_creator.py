#!/usr/bin/env python3
"""Drive the native Qt UI through AT-SPI and capture the E2E storyboard."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

from dogtail.tree import root


def descendants(node):
    yield node
    for child in node.children:
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
    for child in node.children:
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


def click(app, text: str, roles=(), timeout=60):
    node = wait_for(app, text, roles=roles, timeout=timeout)
    node.click()
    return node


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
                    "publicationKey": f"usb-creator:{platform}:create-unraid-usb",
                    "captureId": capture_id,
                    "platform": platform,
                    "flow": "create-unraid-usb",
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
    args = parser.parse_args()
    args.screenshots.mkdir(parents=True, exist_ok=True)

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
        )
        click(app, "Next", roles=("push button", "button"))

        wait_for(app, "Choose operating system", roles=("heading",), timeout=120)
        shot(
            args.screenshots,
            args.manifest,
            "01-os-selection",
            title="Choose the development image",
            caption="The Creator offers the small local Unraid development image for a fast end-to-end write.",
            role="decision",
            capture_id=args.capture_id,
            platform=args.platform,
        )

        click(app, "Unraid (development image)")
        click(app, "Next", roles=("push button", "button"))

        wait_for(app, "Select your storage device", roles=("heading",))
        target = wait_for(app, "QEMU", timeout=90)
        if "usb" not in (target.name or "").lower() and "harddisk" not in (target.name or "").lower():
            raise RuntimeError(f"Unexpected QEMU target description: {target.name!r}")
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
        )
        click(app, "Next", roles=("push button", "button"))

        wait_for(app, "Customisation: Server name", roles=("heading",))
        click(app, "Skip customisation", roles=("push button", "button"))

        wait_for(app, "Write image", roles=("heading",))
        shot(
            args.screenshots,
            args.manifest,
            "03-write-summary",
            title="Review the write",
            caption="The summary identifies the development image and disposable QEMU USB target before erasure.",
            role="instruction",
            capture_id=args.capture_id,
            platform=args.platform,
        )
        click(app, "Write", roles=("push button", "button"))
        click(app, "I understand, erase and write", roles=("push button", "button"), timeout=15)

        wait_for(app, "Write completed successfully", timeout=180)
        shot(
            args.screenshots,
            args.manifest,
            "04-write-complete",
            title="Confirm the write completed",
            caption="The Creator reports that the Unraid development image was written successfully.",
            role="result",
            capture_id=args.capture_id,
            platform=args.platform,
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
