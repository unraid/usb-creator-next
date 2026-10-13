#!/usr/bin/env python3
"""Verify Creator changed only the ready image's FAT setup handoff."""
import hashlib
import json
import os
from pathlib import Path
import struct
import subprocess
import sys
import tempfile


def verify(target, compressed, metadata):
    os.environ['MTOOLS_SKIP_CHECK'] = '1'
    os.environ['MTOOLS_FAT_COMPATIBILITY'] = '1'
    expected = json.loads(metadata.read_text())
    with tempfile.TemporaryDirectory() as directory, target.open('rb') as written:
        esp = Path(directory) / 'source-esp.img'
        digest = hashlib.sha256()
        offset = 0
        process = subprocess.Popen(['zstd', '-d', '--stdout', str(compressed)], stdout=subprocess.PIPE)
        try:
            first = process.stdout.read(1048576)
            if first[512:520] != b'EFI PART':
                raise ValueError('Source image has no GPT')
            table, count, size = struct.unpack_from('<QII', first, 512 + 72)
            if count < 4 or size != 128 or table * 512 + 2 * size > len(first):
                raise ValueError('Unsupported source GPT')
            start, end = struct.unpack_from('<QQ', first, table * 512 + size + 32)
            esp_start, esp_end = start * 512, (end + 1) * 512
            with esp.open('wb') as source_esp:
                chunk = first
                while chunk:
                    digest.update(chunk)
                    actual = written.read(len(chunk))
                    if len(actual) != len(chunk):
                        raise ValueError('Written image is truncated')
                    for begin, finish in ((offset, min(offset + len(chunk), esp_start)),
                                          (max(offset, esp_end), offset + len(chunk))):
                        if finish > begin and actual[begin-offset:finish-offset] != chunk[begin-offset:finish-offset]:
                            raise ValueError(f'Creator changed payload outside the ESP at {begin}')
                    begin, finish = max(offset, esp_start), min(offset + len(chunk), esp_end)
                    if finish > begin:
                        data = chunk[begin-offset:finish-offset]
                        source_esp.seek(begin - esp_start)
                        if data.strip(b'\0'):
                            source_esp.write(data)
                    offset += len(chunk)
                    chunk = process.stdout.read(1048576)
                source_esp.truncate(esp_end - esp_start)
            if process.wait(timeout=20) != 0:
                raise ValueError('Source decompression failed')
        finally:
            if process.poll() is None:
                process.terminate()
                try: process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.kill(); process.wait(timeout=10)
        if digest.hexdigest() != expected['extract_sha256'] or offset != expected['extract_size']:
            raise ValueError('Source image differs from the pinned metadata')
        target_fat = f'{target}@@{esp_start}'
        for name in ('unraid-ready.json', 'EFI/BOOT/BOOTX64.EFI', 'EFI/BOOT/grubx64.efi',
                     'EFI/BOOT/grub.cfg', 'EFI/unraid-os/grub.cfg'):
            source_bytes = subprocess.check_output(['mtype', '-i', str(esp), f'::{name}'])
            target_bytes = subprocess.check_output(['mtype', '-i', target_fat, f'::{name}'])
            if source_bytes != target_bytes:
                raise ValueError(f'Creator changed the boot chain: {name}')
        settings = json.loads(subprocess.check_output(['mtype', '-i', target_fat, '::unraid-creator.json']))
        if settings['schema'] != 'unraid.creator.v1' or settings['settings'].get('hostname') != 'Tower' or settings['settings'].get('dhcp') is not True:
            raise ValueError('Creator settings do not match the UI journey')
        print('Verified raw Creator write: source hash, BIOS/ZFS payload, EFI chain, and FAT settings handoff.')


if __name__ == '__main__':
    verify(*(Path(value) for value in sys.argv[1:4]))
