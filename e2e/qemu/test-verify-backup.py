#!/usr/bin/env python3
"""Exercise backup verification on real FAT files, with partition geometry stubbed."""

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parent


class BackupVerificationTest(unittest.TestCase):
    def setUp(self):
        for command in ("mformat", "mcopy", "mdir", "mlabel", "sha256sum"):
            if not shutil.which(command):
                self.fail(f"Required test tool is unavailable: {command}")
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.work = Path(self.directory.name)
        self.environment = dict(os.environ, MTOOLS_SKIP_CHECK="1", MTOOLS_FAT_COMPATIBILITY="1")
        # This unit test supplies a FAT partition directly. Only parted's offset
        # report is stubbed; label lookup and every file read use real mtools.
        tools = self.work / "bin"
        tools.mkdir()
        parted = tools / "parted"
        parted.write_text("#!/bin/sh\nprintf '1:0B:67108863B:67108864B:fat32::;\\n'\n")
        parted.chmod(0o755)
        self.environment["PATH"] = str(tools) + os.pathsep + os.environ["PATH"]
        self.backup = self.work / "backup.zip"
        self.run_tool(sys.executable, str(ROOT / "make-backup-fixture.py"), str(self.backup))
        self.image = self.work / "fat.raw"
        with self.image.open("wb") as stream:
            stream.truncate(64 * 1024 * 1024)
        self.run_tool("mformat", "-i", str(self.image), "-F", "-v", "UNRAID", "::")
        source = self.work / "source"
        with ZipFile(self.backup) as archive:
            archive.extractall(source)
        self.run_tool("mcopy", "-s", "-i", str(self.image),
                      *(str(path) for path in source.iterdir()), "::")

    def run_tool(self, *command):
        return subprocess.run(command, env=self.environment, check=True, capture_output=True, text=True)

    def verify(self):
        return subprocess.run(["bash", str(ROOT / "verify-image.sh"), str(self.image),
                               str(self.backup), "backup"], env=self.environment,
                              capture_output=True, text=True)

    def test_accepts_unraid_label_and_unchanged_backup(self):
        result = self.verify()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("every backed-up file preserved byte for byte", result.stdout)

    def test_rejects_original_boot_label_bug(self):
        self.run_tool("mlabel", "-i", str(self.image), "::BOOT")
        result = self.verify()
        self.assertEqual(result.returncode, 4, result.stdout + result.stderr)
        self.assertIn("Expected FAT32 label UNRAID, got: BOOT", result.stderr)

    def test_rejects_customization_overwriting_backup(self):
        rewritten = self.work / "ident.cfg"
        rewritten.write_text('NAME="Tower"\n')
        self.run_tool("mcopy", "-o", "-i", str(self.image), str(rewritten), "::config/ident.cfg")
        result = self.verify()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Restored backup differs from source: config/ident.cfg", result.stderr)


if __name__ == "__main__":
    unittest.main()
