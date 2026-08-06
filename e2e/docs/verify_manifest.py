#!/usr/bin/env python3
"""Verify that every captured image matches its manifest digest."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--expected-frames", type=int, required=True)
    args = parser.parse_args()

    root = args.manifest.parent.resolve()
    entries = [json.loads(line) for line in args.manifest.read_text().splitlines() if line]
    if len(entries) != args.expected_frames:
        raise SystemExit(f"expected {args.expected_frames} frames, found {len(entries)}")
    for entry in entries:
        image = (root / entry["image"]).resolve()
        if root not in image.parents or not image.is_file():
            raise SystemExit(f"invalid capture path: {entry['image']}")
        digest = hashlib.sha256(image.read_bytes()).hexdigest()
        if digest != entry["sha256"]:
            raise SystemExit(f"capture digest mismatch: {image.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
