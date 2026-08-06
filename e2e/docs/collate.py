#!/usr/bin/env python3
"""Build an immutable documentation handoff from one passing E2E run."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--evidence", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    manifests = sorted(args.evidence.glob("run-*/manifest.jsonl"))
    if len(manifests) != 1:
        raise SystemExit(f"expected exactly one passing manifest, found {len(manifests)}")

    source_root = manifests[0].parent
    entries = [json.loads(line) for line in manifests[0].read_text().splitlines() if line]
    if not entries:
        raise SystemExit("capture manifest is empty")

    identities = {(entry["publicationKey"], entry["captureId"]) for entry in entries}
    categories = {entry["category"] for entry in entries}
    flows = {entry["flow"] for entry in entries}
    if len(identities) != 1 or len(categories) != 1 or len(flows) != 1:
        raise SystemExit("manifest must contain one category, flow, and publication identity")

    output = args.output
    if output.exists():
        shutil.rmtree(output)
    image_root = output / "images" / next(iter(categories)) / next(iter(flows))
    image_root.mkdir(parents=True)

    steps = []
    storyboard = ["# USB Creator storyboard", ""]
    for order, entry in enumerate(entries, 1):
        source = (source_root / entry["image"]).resolve()
        if source_root.resolve() not in source.parents or not source.is_file():
            raise SystemExit(f"capture path escapes evidence root: {entry['image']}")
        digest = hashlib.sha256(source.read_bytes()).hexdigest()
        if digest != entry["sha256"]:
            raise SystemExit(f"capture digest mismatch: {source.name}")
        destination = image_root / f"{order:02d}-{entry['name']}.png"
        shutil.copyfile(source, destination)
        step = {
            "order": order,
            "title": entry["title"],
            "caption": entry["caption"],
            "frameRole": entry["frameRole"],
            "image": destination.relative_to(output).as_posix(),
            "publicationKey": entry["publicationKey"],
            "captureId": entry["captureId"],
            "sha256": digest,
            "sourceSpec": "native-usb-creator-e2e",
            "sourceTest": "create an Unraid USB",
        }
        steps.append(step)
        storyboard.extend([
            f"## {order}. {entry['title']}",
            "",
            entry["caption"],
            "",
            f"![{entry['title']}]({step['image']})",
            "",
        ])

    publication_key, capture_id = next(iter(identities))
    category = next(iter(categories))
    flow = next(iter(flows))
    guide = {
        "schemaVersion": 2,
        "categoryCount": 1,
        "flowCount": 1,
        "categories": [{
            "category": category,
            "slug": category,
            "flowCount": 1,
            "flows": [{
                "flow": flow,
                "slug": flow,
                "stepCount": len(steps),
                "publicationIdentity": {
                    "publicationKey": publication_key,
                    "captureId": capture_id,
                },
                "steps": steps,
            }],
        }],
    }
    (output / "guide-input.json").write_text(json.dumps(guide, indent=2) + "\n")
    (output / "storyboard.md").write_text("\n".join(storyboard))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
