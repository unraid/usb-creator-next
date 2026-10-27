#!/usr/bin/env python3
"""Exercise exact readback for the GUI journey that skips customisation."""
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import subprocess
import tempfile
import sys
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('ready_verify', Path(__file__).with_name('verify-ready-image.py'))
verifier = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verifier)


class MetadataAdmission(unittest.TestCase):
    def test_real_gui_metadata_script_accepts_only_versioned_bounded_objects(self):
        script = Path(__file__).with_name('run.sh').read_text().split("<<'PYMETA'\n", 1)[1].split('\nPYMETA', 1)[0]
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            image = root / 'image.zst'
            image.write_bytes(b'exact fixture')
            metadata = root / 'image.json'
            value = {'schema': 'unraid.ready-image.v2', 'init_format': 'UNRAID-RAW',
                     'extract_size': 4 << 30, 'profiles': ['usb', 'nvme'],
                     'image_download_sha256': hashlib.sha256(image.read_bytes()).hexdigest()}
            def run(value):
                metadata.write_text(json.dumps(value))
                return subprocess.run([sys.executable, '-c', script, str(metadata), str(image)], capture_output=True, text=True)
            for schema in ('unraid.ready-image.v1', 'unraid.ready-image.v2'):
                result = run({**value, 'schema': schema})
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(int(result.stdout), (4 << 30) + (1 << 20))
            for key, changed in [('schema', 'unraid.ready-image.v3'), ('init_format', 'zip'),
                                 ('extract_size', True), ('extract_size', 65 << 30),
                                 ('profiles', ['usb']), ('image_download_sha256', 'changed')]:
                with self.subTest(key=key, changed=changed):
                    self.assertNotEqual(run({**value, key: changed}).returncode, 0)


class Readback(unittest.TestCase):
    def test_skip_preserves_every_byte_including_esp(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            payload = bytearray(1048576)
            payload[512:520] = b'EFI PART'
            struct.pack_into('<QII', payload, 512 + 72, 2, 4, 128)
            struct.pack_into('<QQ', payload, 2 * 512 + 128 + 32, 8, 15)
            source, target = root / 'source.raw', root / 'target.raw'
            source.write_bytes(payload)
            target.write_bytes(payload)
            compressed, metadata = root / 'source.zst', root / 'image.json'
            subprocess.run(['zstd', '-q', str(source), '-o', str(compressed)], check=True)
            metadata.write_text(json.dumps({'extract_sha256': hashlib.sha256(payload).hexdigest(), 'extract_size': len(payload)}))
            # FAT parsing is already covered by the real-image qualification.
            # This fixture isolates skip semantics from the FAT library.
            with patch.object(verifier.subprocess, 'check_output', return_value=b'unchanged boot file') as fat:
                verifier.verify(target, compressed, metadata)
                self.assertFalse(any('::unraid-creator.json' in call.args[0] for call in fat.call_args_list))
                payload[8 * 512 + 100] = 1
                target.write_bytes(payload)
                with self.assertRaisesRegex(ValueError, 'Skipping customisation changed'):
                    verifier.verify(target, compressed, metadata)
                handoff = {'schema': 'unraid.creator.v1', 'settings': {'hostname': 'ready-usb-test', 'dhcp': True}}
                fat.side_effect = lambda command: json.dumps(handoff).encode() if command[-1] == '::unraid-creator.json' else b'unchanged boot file'
                verifier.verify(target, compressed, metadata, 'customized')
                handoff['settings']['dhcp'] = False
                with self.assertRaisesRegex(ValueError, 'configured UI journey'):
                    verifier.verify(target, compressed, metadata, 'customized')


if __name__ == '__main__':
    unittest.main()
