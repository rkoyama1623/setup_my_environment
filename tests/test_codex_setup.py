import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


REPO = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("setup_codex", REPO / "scripts/setup_codex.py")
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


class CodexSetupTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="codex setup ")
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name)

    def install(self, *options, success=True):
        result = subprocess.run(
            ["python3", str(REPO / "scripts/setup_codex.py"), "--home", str(self.home), *options],
            text=True, capture_output=True,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0)
        return result

    def test_preserves_local_data_and_is_repeatable(self):
        codex = self.home / ".codex"
        codex.mkdir()
        (codex / "AGENTS.md").write_text("Personal instructions\n")
        (codex / "config.toml").write_text('model = "existing-model"\n')
        (codex / "auth.json").write_text("local credential placeholder")
        legacy = codex / "skills/local-chime"
        legacy.mkdir(parents=True)
        (legacy / "SKILL.md").write_text("original local skill")
        self.install()
        first_instructions = (codex / "AGENTS.md").read_text()
        backups = self.home / ".local/state/setup_my_environment/backups"
        first_backups = set(backups.iterdir())
        self.install()
        self.assertEqual(first_instructions, (codex / "AGENTS.md").read_text())
        self.assertEqual(first_instructions.count(setup.BEGIN), 1)
        self.assertIn("Personal instructions", first_instructions)
        self.assertEqual((codex / "config.toml").read_text(), 'model = "existing-model"\n')
        self.assertEqual((codex / "auth.json").read_text(), "local credential placeholder")
        self.assertEqual(set(backups.iterdir()), first_backups)
        skill = self.home / ".agents/skills/local-chime"
        self.assertEqual(skill.resolve(), REPO / "codex/skills/local-chime")
        self.assertFalse(legacy.exists())
        saved_skill = next(backups.glob("local-chime.*"))
        self.assertEqual((saved_skill / "SKILL.md").read_text(), "original local skill")

    def test_new_install_and_damaged_marker_handling(self):
        self.install()
        codex = self.home / ".codex"
        self.assertEqual((codex / "config.toml").read_text(), (REPO / "codex/config.template.toml").read_text())
        damaged = "Keep this text\n" + setup.BEGIN + "\n"
        (codex / "AGENTS.md").write_text(damaged)
        self.install(success=False)
        self.assertEqual((codex / "AGENTS.md").read_text(), damaged)
        self.install("--volume", "70000", success=False)

    def test_missing_sound_does_not_replace_working_skill(self):
        legacy = self.home / ".codex/skills/local-chime"
        legacy.mkdir(parents=True)
        (legacy / "SKILL.md").write_text("working local skill")
        self.install("--with-chime", "--sound", str(self.home / "missing.wav"), success=False)
        self.assertEqual((legacy / "SKILL.md").read_text(), "working local skill")
        self.assertFalse((self.home / ".agents/skills/local-chime").exists())

    def test_chime_configuration_and_dispatch(self):
        source = self.home / "data/setup_my_environment/peon-ping"
        source.mkdir(parents=True)
        for name in ("scripts", "adapters"):
            (source / name).mkdir()
        # Exercise the real wrapper without starting audio or fetching upstream.
        log = self.home / "invocation.json"
        (source / "peon.sh").write_text(
            '#!/bin/bash\npython3 - "$@" <<\'PY\'\n'
            'import json,os,sys\nfrom pathlib import Path\n'
            'Path(os.environ["CHIME_TEST_LOG"]).write_text(json.dumps('
            '{"args":sys.argv[1:],"config":os.environ["CLAUDE_PEON_DIR"],'
            '"platform":os.environ["PEON_PLATFORM"]}))\nPY\n'
        )
        config = self.home / "config/setup_my_environment/peon-ping"
        sound = self.home / "custom sound.oga"
        sound.write_bytes(b"test sound")
        with patch.object(setup, "peon_source", return_value=source), \
             patch.object(setup.platform, "system", return_value="Linux"), \
             patch.object(setup.shutil, "which", return_value="/mock/paplay"):
            setup.install_chime(source.parent, config, self.home / "backups", sound, 20000)
            setup.install_chime(source.parent, config, self.home / "backups", None, None)
        settings = json.loads((config / "config.json").read_text())
        self.assertEqual(settings["volume"], 20000 / 65536)
        self.assertFalse(settings["desktop_notifications"])
        manifest = json.loads((config / "packs/local-chime/openpeon.json").read_text())
        audio = config / "packs/local-chime" / manifest["categories"]["task.complete"]["sounds"][0]["file"]
        self.assertEqual(audio.read_bytes(), b"test sound")
        result = subprocess.run(
            ["bash", str(REPO / "codex/skills/local-chime/scripts/chime.sh")],
            env={**os.environ, "XDG_DATA_HOME": str(self.home / "data"),
                 "XDG_CONFIG_HOME": str(self.home / "config"), "CHIME_TEST_LOG": str(log)},
            text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        invocation = json.loads(log.read_text())
        self.assertEqual(invocation["args"], ["preview", "task.complete"])
        self.assertEqual(Path(invocation["config"]), config)

    def test_make_codex_includes_chime_once(self):
        result = subprocess.run(
            ["make", "-n", "codex", "USE_PROXY=false", "USE_PYENV=false"],
            cwd=REPO, text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        commands = [line for line in result.stdout.splitlines() if "setup_codex.py" in line]
        self.assertEqual(len(commands), 1)
        self.assertIn("--with-chime", commands[0])


if __name__ == "__main__":
    unittest.main()
