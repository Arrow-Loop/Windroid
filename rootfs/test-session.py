"""Lifecycle concurrency/readiness checks using isolated services, not Android."""
import importlib.util
import os
from pathlib import Path
import subprocess
import unittest

spec = importlib.util.spec_from_file_location('firstboot_fixture', Path(__file__).with_name('test-firstboot.py'))
fixture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fixture)


class SessionTests(unittest.TestCase):
    stub = fixture.FirstbootTests.stub

    def setUp(self):
        fixture.FirstbootTests.setUp(self)
        if os.name == 'nt':
            self.stub('setsid', 'exec "$@"')
        text = (Path(__file__).parent / 'files/usr/local/bin/windroid-session').read_text()
        text = text.replace('/etc/windroid', self.posix + '/etc/windroid')
        text = text.replace('/usr/local/sbin/windroid-prep', self.posix + '/bin/prep')
        self.script.write_text(text, newline='\n')
        self.conf.write_text('NESTED_WESTON=false\nSESSION_READY_TIMEOUT=3\n')
        self.env.update(XDG_STATE_HOME=self.posix + '/state', TEST_STATE=self.posix + '/status',
                        TEST_STARTS=self.posix + '/starts')
        self.log = self.root / 'state/windroid/session.log'
        self.log.parent.mkdir(parents=True)
        (self.root / 'status').write_text('Session: STOPPED\nContainer: STOPPED\n')
        self.stub('sudo', '[[ "${1:-}" == -n ]] && shift\nexec "$@"')
        self.stub('prep', 'exit 0')
        self.stub('pgrep', 'exit 1')
        self.stub('pkill', 'exit 1')
        self.stub('waydroid', '''case "$*" in
status) cat "$TEST_STATE" ;;
"session start")
 echo start >> "$TEST_STARTS"
 printf 'Session: RUNNING\\nContainer: RUNNING\\n' > "$TEST_STATE"
 echo 'Android is ready'
 sleep 4 ;;
"session stop") printf 'Session: STOPPED\\nContainer: STOPPED\\n' > "$TEST_STATE" ;;
esac''')

    def run_session(self, command):
        return subprocess.run([self.bash, '-c', 'export PATH="$1:/usr/bin:/bin"; exec bash "$2" "$3"',
                               'test-session', self.posix + '/bin', self.posix + '/firstboot', command],
                              env=self.env, capture_output=True, text=True)

    def test_ready_session_is_not_relaunched(self):
        (self.root / 'status').write_text('Session: RUNNING\nContainer: RUNNING\n')
        self.log.write_text('Android is ready\n')
        self.assertEqual(self.run_session('ensure').returncode, 0)
        self.assertFalse((self.root / 'starts').exists())

    def test_running_but_unready_waits_without_duplicate_start(self):
        self.conf.write_text('SESSION_READY_TIMEOUT=1\n')
        (self.root / 'status').write_text('Session: RUNNING\nContainer: RUNNING\n')
        self.log.touch()
        self.assertNotEqual(self.run_session('ensure').returncode, 0)
        self.assertFalse((self.root / 'starts').exists())

    def test_stopped_container_does_not_report_ready(self):
        (self.root / 'status').write_text('Session: RUNNING\nContainer: STOPPED\n')
        self.log.write_text('Android is ready\n')
        result = self.run_session('ensure')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((self.root / 'starts').read_text().splitlines(), ['start'])

    def test_container_stop_failure_is_reported(self):
        self.stub('prep', '[[ "${1:-}" == down ]] && exit 23\nexit 0')
        result = self.run_session('stop')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('could not stop', result.stderr)

    @unittest.skipIf(os.name == 'nt', 'Linux Wayland socket fixture required')
    def test_nested_start_waits_for_delayed_socket(self):
        self.conf.write_text('NESTED_WESTON=true\nSESSION_READY_TIMEOUT=6\n')
        runtime = self.root / 'runtime'
        runtime.mkdir()
        self.env['XDG_RUNTIME_DIR'] = self.posix + '/runtime'
        self.env['TEST_COMPOSITOR'] = self.posix + '/compositor.py'
        (self.root / 'compositor.py').write_text(
            'import os,socket,time\ntime.sleep(2.5)\n'
            's=socket.socket(socket.AF_UNIX)\n'
            's.bind(os.environ["XDG_RUNTIME_DIR"]+"/wayland-1")\ntime.sleep(8)\n')
        self.stub('weston', 'exec "$TEST_PYTHON" "$TEST_COMPOSITOR"')
        result = self.run_session('start')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue((self.root / 'starts').exists())

    @unittest.skipIf(os.name == 'nt', 'real Linux flock required')
    def test_concurrent_starts_only_spawn_one_daemon(self):
        from concurrent.futures import ThreadPoolExecutor
        with ThreadPoolExecutor(max_workers=2) as pool:
            results = list(pool.map(lambda _: self.run_session('start'), range(2)))
        for result in results:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((self.root / 'starts').read_text().splitlines(), ['start'])

    def test_nested_compositor_exit_does_not_launch_session(self):
        self.conf.write_text('NESTED_WESTON=true\nSESSION_READY_TIMEOUT=3\n')
        self.stub('weston', 'echo "compositor failed"\nexit 23')
        result = self.run_session('start')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('nested Weston exited', result.stderr)
        self.assertIn('compositor failed', result.stderr)
        self.assertFalse((self.root / 'starts').exists())


if __name__ == '__main__':
    unittest.main()
