import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class ClipboardTests(unittest.TestCase):
    def test_local_and_remote_clipboard_backends_preserve_input(self):
        cases = [
            ("Darwin", "", "", "", "pbcopy"),
            ("Linux", "", "wayland-1", "", "wl-copy"),
            ("Linux", "", "", ":0", "xclip"),
            ("Linux", "remote", "wayland-1", "", "tmux"),
            ("Linux", "", "", "", "tmux"),
        ]
        for kernel, ssh, wayland, display, expected in cases:
            with self.subTest(expected=expected, ssh=ssh), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                uname = root / "uname"
                uname.write_text("#!/bin/sh\nprintf '%s\\n' '" + kernel + "'\n")
                uname.chmod(0o755)
                for name in ["pbcopy", "wl-copy", "xclip", "tmux"]:
                    script = root / name
                    script.write_text("#!/bin/sh\nprintf '%s' '" + name + "' > \"$CAPTURE_BACKEND\"\ncat > \"$CAPTURE_INPUT\"\n")
                    script.chmod(0o755)
                env = {**os.environ, "PATH": str(root) + ":/usr/bin:/bin",
                       "SSH_CONNECTION": ssh, "WAYLAND_DISPLAY": wayland, "DISPLAY": display,
                       "CAPTURE_BACKEND": str(root / "backend"),
                       "CAPTURE_INPUT": str(root / "input")}
                payload = "quotes ' \\\" and spaces\nsecond line\n"
                result = subprocess.run(["sh", str(ROOT / "tmux/copy.sh")],
                                        env=env, input=payload, text=True, capture_output=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual((root / "backend").read_text(), expected)
                self.assertEqual((root / "input").read_text(), payload)


if __name__ == "__main__":
    unittest.main()
