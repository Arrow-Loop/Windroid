"""Execute firstboot in isolated path fixtures; no Android/root access needed.

On Git Bash, flock is stubbed (serialization must be tested on Linux).
All other branches execute the production script with mocked external services.
"""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


class FirstbootTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="windroid-firstboot-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.bash = os.environ.get("WINDROID_TEST_BASH", "bash")
        root = self.root.as_posix()
        if os.name == "nt":
            root = "/" + root[0].lower() + root[2:]
        self.posix = root
        text = (Path(__file__).parent / "files/usr/local/bin/windroid-firstboot").read_text(encoding="utf-8")
        for path in ("/var/lib/windroid", "/etc/windroid", "/var/log", "/etc/waydroid-extra", "/var/lib/waydroid"):
            text = text.replace(path, root + path)
            (self.root / path.lstrip("/")).mkdir(parents=True, exist_ok=True)
        self.script = self.root / "firstboot"
        self.script.write_text(text, encoding="utf-8", newline="\n")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.stub("zgrep", "exit 0")
        self.stub("systemctl", "exit 0")
        if os.name == "nt":
            self.stub("flock", "exit 0")
        self.stub("waydroid", 'echo "$*" >> "$CALLS"\n[[ "${FAIL_INIT:-0}" == 1 && "$*" == *init* ]] && exit 17\nexit 0')
        self.env = dict(os.environ, CALLS=root + "/calls")
        self.conf = self.root / "etc/windroid/windroid.conf"
        self.conf.write_text("GAPPS=true\nFORCE_SOFTWARE_RENDERING=false\nMULTI_WINDOWS=false\n")
        (self.root / "var/lib/waydroid/waydroid.cfg").write_text("[waydroid]\nsuspend_action = freeze\n")
        self.stamp = self.root / "var/lib/windroid/.initialized"

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env bash\n" + body + "\n", newline="\n")
        path.chmod(0o755)

    def run_boot(self, configured=True):
        if configured:
            (self.conf.parent / ".configured").touch()
        return subprocess.run([self.bash, '-c', 'export PATH="$1:/usr/bin:/bin"; exec bash "$2"',
                               'test-firstboot', self.posix + '/bin', self.posix + '/firstboot'],
                              env=self.env, capture_output=True, text=True)

    def test_unconfigured_never_initializes(self):
        self.assertEqual(self.run_boot(False).returncode, 0)
        self.assertFalse(self.stamp.exists())
        self.assertFalse((self.root / "calls").exists())

    def test_legacy_stamp_does_not_skip_gapps(self):
        self.stamp.touch()
        result = self.run_boot()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.stamp.read_text().strip(), "GAPPS")
        self.assertIn("init -f -s GAPPS", (self.root / "calls").read_text())

    def test_successful_rerun_is_noop(self):
        self.stamp.write_text("GAPPS\n")
        self.assertEqual(self.run_boot().returncode, 0)
        self.assertFalse((self.root / "calls").exists())

    def test_failed_download_can_retry_without_moving_preseed_twice(self):
        preseed = self.root / "etc/waydroid-extra/images"
        preseed.mkdir()
        (preseed / ".system-type").write_text("VANILLA\n")
        self.env["FAIL_INIT"] = "1"
        self.assertNotEqual(self.run_boot().returncode, 0)
        self.assertFalse(self.stamp.exists())
        self.assertFalse(preseed.exists())
        self.env["FAIL_INIT"] = "0"
        self.assertEqual(self.run_boot().returncode, 0)
        self.assertEqual(self.stamp.read_text().strip(), "GAPPS")


if __name__ == "__main__":
    unittest.main()
