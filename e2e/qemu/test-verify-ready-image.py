#!/usr/bin/env python3
"""Exercise exact readback for the GUI journey that skips customisation."""
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('ready_verify', Path(__file__).with_name('verify-ready-image.py'))
verifier = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verifier)


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


if __name__ == '__main__':
    unittest.main()
