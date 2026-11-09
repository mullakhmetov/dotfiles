import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.env = {**os.environ, "HOME": str(self.home),
                    "XDG_CONFIG_HOME": str(self.home / ".config"),
                    "XDG_STATE_HOME": str(self.home / ".local/state")}

    def run_bootstrap(self, *args):
        return subprocess.run(["bash", str(ROOT / "bootstrap.sh"), *args],
                              env=self.env, text=True, capture_output=True)

    def test_dry_run_preserves_existing_configuration(self):
        rc = self.home / ".zshrc"
        rc.write_text("original\n")
        result = self.run_bootstrap("--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(rc.is_symlink())
        self.assertEqual(rc.read_text(), "original\n")
        self.assertFalse((self.home / ".config").exists())

    def test_apply_preserves_files_and_directories_and_is_idempotent(self):
        (self.home / ".zshrc").write_text("original shell\n")
        nvim = self.home / ".config/nvim"
        nvim.mkdir(parents=True)
        (nvim / "init.lua").write_text("-- original editor\n")
        first = self.run_bootstrap("--apply")
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertTrue(nvim.is_symlink())
        self.assertTrue((self.home / ".tmux/session-style.sh").is_file())
        self.assertTrue((self.home / ".config/atuin/config.toml").is_file())
        backups = self.home / ".local/state/dotfiles/backups"
        self.assertEqual([p.read_text() for p in backups.rglob(".zshrc")], ["original shell\n"])
        self.assertEqual([p.read_text() for p in backups.rglob("init.lua")], ["-- original editor\n"])
        before = sorted(str(p) for p in backups.rglob("*"))
        second = self.run_bootstrap("--apply")
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(before, sorted(str(p) for p in backups.rglob("*")))
        self.assertFalse((self.home / ".claude").exists())

    def test_custom_xdg_directory_receives_configuration(self):
        self.env["XDG_CONFIG_HOME"] = str(self.home / "custom config")
        result = self.run_bootstrap("--apply")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.home / "custom config/nvim/init.lua").is_file())
        self.assertFalse((self.home / ".config").exists())

    def test_invalid_argument_does_not_modify_home(self):
        result = self.run_bootstrap("--invalid")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_new_shell_starts_without_optional_dependencies(self):
        result = self.run_bootstrap("--apply")
        self.assertEqual(result.returncode, 0, result.stderr)
        env = {**self.env, "PATH": "/usr/bin:/bin", "TERM": "xterm-256color"}
        shell = subprocess.run(["zsh", "-d", "-i", "-c", "print DOTFILES_OK"],
                               env=env, text=True, capture_output=True)
        self.assertEqual(shell.returncode, 0, shell.stderr)
        self.assertEqual(shell.stderr, "")
        self.assertIn("DOTFILES_OK", shell.stdout)


if __name__ == "__main__":
    unittest.main()
