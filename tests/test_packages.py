import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "install/packages.py"


class PackageTests(unittest.TestCase):
    def cli(self, *args, env=None):
        return subprocess.run([sys.executable, "-B", str(SCRIPT), *args],
                              text=True, capture_output=True, env=env)

    def module(self):
        spec = importlib.util.spec_from_file_location("packages", SCRIPT)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        return module

    def test_arm_preview_preserves_home_and_does_not_execute_tools(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory) / "home"
            home.mkdir()
            guard = Path(directory) / "bin"
            guard.mkdir()
            for name in ["brew", "pacman", "yay", "sudo", "curl", "git", "gpg"]:
                p = guard / name
                p.write_text("#!/bin/sh\necho 'Unexpected execution' >&2\nexit 99\n")
                p.chmod(0o755)
            env = {**os.environ, "HOME": str(home), "PATH": str(guard)}
            result = self.cli("--platform", "arch", "--arch", "aarch64",
                              "--group", "all", env=env)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("1password", result.stdout)
            self.assertIn("v2rayn", result.stdout)
            self.assertIn("web", result.stdout)
            self.assertIn("Ledger", result.stdout)
            self.assertEqual(list(home.iterdir()), [])

    def test_explicit_selection_and_architecture_routes(self):
        module = self.module()
        catalog = module.load_catalog()
        arm = module.make_plan(catalog, "arch", "aarch64", ["all"], ["spotify", "1password"])
        self.assertEqual([x["id"] for x in arm], ["1password", "spotify"])
        self.assertEqual([x["method"] for x in arm], ["onepassword", "web"])
        x64 = module.make_plan(catalog, "arch", "x86_64", ["apps"], ["spotify"])
        self.assertEqual(x64[0]["method"], "aur")

    def test_invalid_selection_does_not_apply(self):
        result = self.cli("--only", "nonexistent", "--apply")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unknown package", result.stderr)

    def test_empty_explicit_selection_never_applies(self):
        module = self.module()
        for selection in ["", "  ", "git,", ",git", "git,,tmux", "git, ,tmux"]:
            with self.subTest(selection=selection), \
                    patch.object(module, "host_target", return_value=("macos", "aarch64")), \
                    patch.object(module, "apply_plan") as apply, \
                    patch.object(module.sys, "stdout", io.StringIO()), \
                    patch.object(module.sys, "stderr", io.StringIO()):
                self.assertEqual(module.main(["--only", selection, "--apply"]), 2)
                apply.assert_not_called()

    def test_explicit_selection_trims_package_ids(self):
        module = self.module()
        with patch.object(module, "host_target", return_value=("macos", "aarch64")), \
                patch.object(module, "apply_plan", return_value=0) as apply, \
                patch.object(module.sys, "stdout", io.StringIO()):
            self.assertEqual(module.main(["--only", " git , tmux ", "--apply"]), 0)
        self.assertEqual([entry["id"] for entry in apply.call_args.args[0]], ["git", "tmux"])

    def test_apply_rejects_different_host_before_commands(self):
        module = self.module()
        with patch.object(module, "host_target", return_value=("macos", "aarch64")), \
                patch.object(module, "run") as run:
            with self.assertRaisesRegex(ValueError, "target"):
                module.apply_plan([], "arch", "aarch64")
            run.assert_not_called()

    def test_repo_install_uses_full_upgrade_and_keeps_prompts(self):
        module = self.module()
        calls = []
        def run(args, **kwargs):
            calls.append(args)
            return subprocess.CompletedProcess(args, 0, "", "")
        with patch.object(module, "run", side_effect=run), \
                patch.object(module.shutil, "which", return_value="/usr/bin/pacman"):
            module.install_repo(["git", "tmux"])
        transaction = calls[-1]
        self.assertEqual(transaction, ["sudo", "pacman", "-Syu", "--needed", "git", "tmux"])
        self.assertNotIn("--noconfirm", transaction)

    def test_missing_ghostty_does_not_block_available_repo_packages(self):
        module = self.module()
        calls = []
        def run(args, **kwargs):
            calls.append(args)
            if args == ["pacman", "-Si", "ghostty"]:
                raise subprocess.CalledProcessError(1, args)
            return subprocess.CompletedProcess(args, 0, "", "")
        with patch.object(module, "run", side_effect=run), \
                patch.object(module.shutil, "which", return_value="/usr/bin/pacman"):
            missing = module.install_repo(["ghostty", "git"])
        self.assertEqual(missing, ["ghostty"])
        self.assertEqual(calls[-1], ["sudo", "pacman", "-Syu", "--needed", "git"])

    def test_missing_repo_app_preserves_final_failure_and_other_actions(self):
        module = self.module()
        plan = [{"id": "ghostty", "method": "repo", "packages": ["ghostty"]},
                {"id": "discord", "method": "web", "url": "https://discord.com/app"}]
        with patch.object(module, "host_target", return_value=("arch", "aarch64")), \
                patch.object(module.os, "geteuid", return_value=1000), \
                patch.object(module, "install_repo", return_value=["ghostty"]), \
                patch.object(module, "install_web") as web:
            result = module.apply_plan(plan, "arch", "aarch64")
        self.assertEqual(result, 1)
        web.assert_called_once()

    def test_aur_rejects_wrong_architecture_before_install(self):
        module = self.module()
        with patch.object(module, "read_url", return_value="pkgbase = demo\narch = x86_64\npkgname = demo\n"), \
                patch.object(module, "run") as run, \
                patch.object(module.shutil, "which", return_value="/usr/bin/yay"):
            with self.assertRaisesRegex(ValueError, "aarch64"):
                module.install_aur("demo", "demo", "aarch64")
            run.assert_not_called()

    def test_aur_does_not_use_another_split_packages_architecture(self):
        module = self.module()
        info = "pkgbase = demo\narch = x86_64\npkgname = demo\narch = x86_64\npkgname = other\narch = aarch64\n"
        with patch.object(module, "read_url", return_value=info), \
                patch.object(module, "run") as run, \
                patch.object(module.shutil, "which", return_value="/usr/bin/yay"):
            with self.assertRaisesRegex(ValueError, "aarch64"):
                module.install_aur("demo", "demo", "aarch64")
            run.assert_not_called()

    def test_failed_script_download_never_executes_script(self):
        module = self.module()
        calls = []
        def run(args, **kwargs):
            calls.append(args)
            if args[0] == "curl":
                raise subprocess.CalledProcessError(22, args)
            return subprocess.CompletedProcess(args, 0, "", "")
        with patch.object(module, "run", side_effect=run):
            with self.assertRaises(subprocess.CalledProcessError):
                module.install_script({"url": "https://example.invalid/install.sh", "shell": "sh"})
        self.assertEqual(len(calls), 1)

    def test_web_launcher_does_not_replace_existing_file(self):
        module = self.module()
        with tempfile.TemporaryDirectory() as directory:
            with patch.dict(os.environ, {"XDG_DATA_HOME": directory}):
                entry = {"id": "spotify", "title": "Spotify", "url": "https://open.spotify.com/"}
                module.install_web(entry)
                path = Path(directory) / "applications/dotfiles-spotify.desktop"
                self.assertIn("xdg-open https://open.spotify.com/", path.read_text())
                path.write_text("custom content")
                with self.assertRaisesRegex(ValueError, "differs"):
                    module.install_web(entry)
                self.assertEqual(path.read_text(), "custom content")

    def test_untrusted_onepassword_signer_never_reaches_sudo(self):
        module = self.module()
        calls = []
        def run(args, **kwargs):
            calls.append(args)
            return subprocess.CompletedProcess(args, 0, "pub:::::::::\nfpr:::::::::WRONG:\n", "")
        def which(name):
            return None if name == "1password" else "/usr/bin/" + name
        with patch.object(module, "run", side_effect=run), \
                patch.object(module, "download"), \
                patch.object(module.shutil, "which", side_effect=which), \
                patch.object(module.Path, "exists", return_value=False), \
                patch.object(module.Path, "is_symlink", return_value=False):
            with self.assertRaisesRegex(ValueError, "fingerprint"):
                module.install_onepassword()
        self.assertFalse(any(args[0] == "sudo" for args in calls))

    def test_failed_package_install_returns_failure(self):
        module = self.module()
        with patch.object(module, "host_target", return_value=("arch", "aarch64")), \
                patch.object(module.os, "geteuid", return_value=1000), \
                patch.object(module, "install_aur", side_effect=ValueError("No ARM build")):
            result = module.apply_plan([{"id": "example", "method": "aur", "package": "example", "base": "example"}], "arch", "aarch64")
        self.assertEqual(result, 1)

    def test_extra_primary_signing_key_is_rejected(self):
        module = self.module()
        calls = []
        def run(args, **kwargs):
            calls.append(args)
            keys = "pub:::::::::\nfpr:::::::::" + module.SIGNING_KEY + ":\npub:::::::::\nfpr:::::::::UNRELATED:\n"
            return subprocess.CompletedProcess(args, 0, keys, "")
        with patch.object(module, "run", side_effect=run), \
                patch.object(module, "download"), \
                patch.object(module.shutil, "which", side_effect=lambda name: None if name == "1password" else "/usr/bin/" + name), \
                patch.object(module.Path, "exists", return_value=False), \
                patch.object(module.Path, "is_symlink", return_value=False):
            with self.assertRaisesRegex(ValueError, "fingerprint"):
                module.install_onepassword()
        self.assertFalse(any("--import" in args or args[0] == "sudo" for args in calls))

    def test_bad_archive_signature_is_rejected_before_installation(self):
        module = self.module()
        calls = []
        def run(args, **kwargs):
            calls.append(args)
            if "--verify" in args:
                raise subprocess.CalledProcessError(1, args)
            keys = "pub:::::::::\nfpr:::::::::" + module.SIGNING_KEY + ":\n"
            return subprocess.CompletedProcess(args, 0, keys, "")
        with patch.object(module, "run", side_effect=run), \
                patch.object(module, "download"), \
                patch.object(module.shutil, "which", side_effect=lambda name: None if name == "1password" else "/usr/bin/" + name), \
                patch.object(module.Path, "exists", return_value=False), \
                patch.object(module.Path, "is_symlink", return_value=False):
            with self.assertRaises(subprocess.CalledProcessError):
                module.install_onepassword()
        self.assertFalse(any(args[0] == "sudo" for args in calls))

    def test_secret_signing_material_is_rejected_before_import(self):
        module = self.module()
        for secret_record in ["sec", "ssb"]:
            with self.subTest(record=secret_record):
                calls = []
                def run(args, **kwargs):
                    calls.append(args)
                    keys = ("pub:::::::::\nfpr:::::::::" + module.SIGNING_KEY +
                            ":\n" + secret_record + ":::::::::\nfpr:::::::::UNRELATED:\n")
                    return subprocess.CompletedProcess(args, 0, keys, "")
                with patch.object(module, "run", side_effect=run), \
                        patch.object(module, "download"), \
                        patch.object(module.shutil, "which", side_effect=lambda name: None if name == "1password" else "/usr/bin/" + name), \
                        patch.object(module.Path, "exists", return_value=False), \
                        patch.object(module.Path, "is_symlink", return_value=False):
                    with self.assertRaisesRegex(ValueError, "signing"):
                        module.install_onepassword()
                self.assertFalse(any("--import" in args or args[0] == "sudo" for args in calls))

    def test_onepassword_installs_root_owned_files_before_vendor_script(self):
        module = self.module()
        calls = []
        def download(url, destination):
            if str(destination).endswith(".tar.gz"):
                with tarfile.open(destination, "w:gz") as archive:
                    body = b"#!/bin/sh\nexit 0\n"
                    member = tarfile.TarInfo("1password-test/after-install.sh")
                    member.size = len(body)
                    member.mode = 0o755
                    archive.addfile(member, io.BytesIO(body))
            else:
                destination.write_text("test fixture")
        def run(args, **kwargs):
            calls.append(args)
            keys = "pub:::::::::\nfpr:::::::::" + module.SIGNING_KEY + ":\n"
            return subprocess.CompletedProcess(args, 0, keys, "")
        original_exists = module.Path.exists
        original_is_symlink = module.Path.is_symlink
        def exists(path):
            return False if str(path) == "/opt/1Password" else original_exists(path)
        def is_symlink(path):
            return False if str(path) == "/opt/1Password" else original_is_symlink(path)
        with patch.object(module, "download", side_effect=download), \
                patch.object(module, "run", side_effect=run), \
                patch.object(module, "install_repo", return_value=[]), \
                patch.object(module.shutil, "which", side_effect=lambda name: None if name == "1password" else "/usr/bin/" + name), \
                patch.object(module.Path, "exists", exists), \
                patch.object(module.Path, "is_symlink", is_symlink):
            module.install_onepassword()
        privileged = [args for args in calls if args[0] == "sudo"]
        self.assertEqual(privileged[0], ["sudo", "mkdir", "/opt/1Password"])
        self.assertEqual(privileged[1][:4], ["sudo", "cp", "-a", "--no-preserve=ownership"])
        self.assertEqual(privileged[1][-1], "/opt/1Password")
        self.assertEqual(privileged[2], ["sudo", "/opt/1Password/after-install.sh"])


if __name__ == "__main__":
    unittest.main()
