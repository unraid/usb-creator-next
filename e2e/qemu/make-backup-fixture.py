#!/usr/bin/env python3
"""Create a synthetic flash backup with nondefault settings. Not bootable."""

import argparse
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    files = {
        "changes.txt": b"Synthetic backup for restore regression testing. Not bootable.\n",
        "config/ident.cfg": b'# Preserve this backup comment\nNAME="RestoredTower"\nCOMMENT="Backup fixture"\n',
        "config/network.cfg": b'USE_DHCP="no"\nIPADDR="192.0.2.25"\nNETMASK="255.255.255.0"\nGATEWAY="192.0.2.1"\n',
        "config/plugins/example/settings.cfg": b'PRESERVE="backup-specific setting"\n',
        "EFI/BOOT/bootx64.efi": b"Synthetic EFI placeholder\n",
    }
    for name in ("bzimage", "bzroot", "bzfirmware", "bzmodules"):
        files[name] = (f"Synthetic {name} payload\n".encode()) * 1024
    with ZipFile(args.output, "w", compression=ZIP_DEFLATED) as archive:
        for name, content in files.items():
            archive.writestr(name, content)
    print(f"Created synthetic, nonbootable backup: {args.output}")


if __name__ == "__main__":
    main()
