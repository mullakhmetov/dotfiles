import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PlatformTests(unittest.TestCase):
    def detect(self, kernel, release):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "os-release"
            path.write_text(release)
            return subprocess.run(
                ["bash", "-c", 'source "$1"; detect_platform "$2" "$3"',
                 "test", str(ROOT / "install/platform.sh"), kernel, str(path)],
                text=True, capture_output=True)

    def test_macos_arch_and_debian_families(self):
        for kernel, release, expected in [
            ("Darwin", "", "macos"),
            ("Linux", "ID=arch\n", "arch"),
            ("Linux", 'ID=omarchy\nID_LIKE="arch"\n', "arch"),
            ("Linux", 'ID=ubuntu\nID_LIKE=debian\n', "ubuntu"),
            ("Linux", "ID=debian\n", "ubuntu"),
        ]:
            with self.subTest(kernel=kernel, release=release):
                result = self.detect(kernel, release)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.strip(), expected)

    def test_unknown_linux_does_not_use_ubuntu_commands(self):
        result = self.detect("Linux", "ID=fedora\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")

    def test_install_preview_does_not_create_user_files(self):
        with tempfile.TemporaryDirectory() as directory:
            guard = Path(directory) / "command-guard"
            guard.mkdir()
            for command in ["brew", "git", "sudo", "curl"]:
                script = guard / command
                script.write_text("#!/bin/sh\necho 'Unexpected external command' >&2\nexit 99\n")
                script.chmod(0o755)
            home = Path(directory) / "home"
            home.mkdir()
            result = subprocess.run(["bash", str(ROOT / "install.sh"), "--dry-run"],
                                    env={**os.environ, "HOME": str(home),
                                         "PATH": str(guard) + ":/usr/bin:/bin",
                                         "XDG_CONFIG_HOME": str(home / ".config"),
                                         "XDG_STATE_HOME": str(home / ".state")},
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(list(home.iterdir()), [])


if __name__ == "__main__":
    unittest.main()
