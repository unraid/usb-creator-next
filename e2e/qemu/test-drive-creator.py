#!/usr/bin/env python3
"""Test native UI selectors against a small AT-SPI boundary fixture."""

import importlib.util
from pathlib import Path
import types
import unittest
from unittest.mock import patch


tree = types.ModuleType("dogtail.tree")
tree.root = None
spec = importlib.util.spec_from_file_location("drive_creator", Path(__file__).parent / "guest/drive_creator.py")
driver = importlib.util.module_from_spec(spec)
with patch.dict("sys.modules", {"dogtail": types.ModuleType("dogtail"), "dogtail.tree": tree}):
    spec.loader.exec_module(driver)


class Node:
    def __init__(self, name, role, children=()):
        self.name = name
        self.roleName = role
        self.children = children
        self.showing = True
        self.clicked = False
        self.text = ""

    def click(self):
        self.clicked = True


class CustomBackupSelectorTest(unittest.TestCase):
    def test_open_file_does_not_click_open_application_settings(self):
        options = Node("App Options, Open application settings to configure sound alerts", "push button")
        custom = Node("Use custom. Select a custom image or ZIP file from your computer", "list item")
        path = Node("Enter folder or file path…", "text")
        open_file = Node("Open", "push button")
        app = Node("Unraid USB Creator", "application", [options, custom, path, open_file])

        driver.select_custom_backup(app, Path("/opt/usb-creator-e2e/unraid-backup.zip"))

        self.assertTrue(custom.clicked)
        self.assertEqual(path.text, "/opt/usb-creator-e2e/unraid-backup.zip")
        self.assertTrue(open_file.clicked)
        self.assertFalse(options.clicked)


if __name__ == "__main__":
    unittest.main()
