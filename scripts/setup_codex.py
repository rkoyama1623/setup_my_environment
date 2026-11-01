#!/usr/bin/env python3
"""Install portable Codex instructions and skills without copying runtime state."""

import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import tempfile


REPO = Path(__file__).resolve().parents[1]
BEGIN = "<!-- setup_my_environment:codex:start -->"
END = "<!-- setup_my_environment:codex:end -->"


def backup(path, state):
    state.mkdir(parents=True, exist_ok=True)
    target = state / (path.name + "." + datetime.now().strftime("%Y%m%d-%H%M%S-%f"))
    shutil.move(str(path), str(target))
    print(f"Backed up {path} to {target}")


def link(source, target, state):
    if target.is_symlink() and target.resolve() == source.resolve():
        return
    if target.exists() or target.is_symlink():
        backup(target, state)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.symlink_to(source, target_is_directory=source.is_dir())
    print(f"Linked {target}")


def install_instructions(codex_home, state):
    target = codex_home / "AGENTS.md"
    original = target.read_text() if target.exists() else ""
    instructions = (REPO / "codex/global-instructions.md").read_text().rstrip()
    block = BEGIN + "\n" + instructions + "\n" + END
    if BEGIN in original or END in original:
        if original.count(BEGIN) != 1 or original.count(END) != 1:
            raise ValueError(f"Invalid managed instruction markers in {target}")
        start, end = original.index(BEGIN), original.index(END)
        if end < start:
            raise ValueError(f"Invalid managed instruction marker order in {target}")
        updated = original[:start] + block + original[end + len(END):]
    else:
        updated = original.rstrip() + ("\n\n" if original.strip() else "") + block + "\n"
    if updated != original:
        if target.exists() or target.is_symlink():
            backup(target, state)
        target.write_text(updated)
        print(f"Updated {target}")
    if (codex_home / "AGENTS.override.md").exists():
        print("Note: AGENTS.override.md takes precedence over the shared AGENTS.md.")


def peon_source(data):
    pin = json.loads((REPO / "codex/peon-ping.json").read_text())
    target = data / "peon-ping"
    if target.exists():
        revision = subprocess.check_output(
            ["git", "-C", str(target), "rev-parse", "HEAD"], text=True
        ).strip()
        if revision != pin["commit"]:
            raise ValueError(f"{target} has another revision; move it aside before reinstalling")
        if subprocess.check_output(["git", "-C", str(target), "status", "--porcelain"], text=True).strip():
            raise ValueError(f"{target} has local changes; preserve them before reinstalling")
        return target
    data.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="peon-download-", dir=data) as temporary:
        checkout = Path(temporary) / "source"
        subprocess.run(["git", "init", "-q", str(checkout)], check=True)
        subprocess.run(["git", "-C", str(checkout), "remote", "add", "origin", pin["repository"]], check=True)
        subprocess.run(["git", "-C", str(checkout), "fetch", "--depth", "1", "origin", pin["commit"]], check=True)
        subprocess.run(["git", "-C", str(checkout), "checkout", "-q", "--detach", pin["commit"]], check=True)
        shutil.move(str(checkout), str(target))
    return target


def install_chime(data, config, state, sound, volume):
    system = platform.system()
    if system not in ("Linux", "Darwin"):
        raise ValueError("Chime setup supports Linux and macOS")
    config_file = config / "config.json"
    settings = json.loads(config_file.read_text()) if config_file.exists() else {}
    pack = config / "packs/local-chime"
    if sound is None and not (pack / "sounds").is_dir():
        sound = Path("/usr/share/sounds/Yaru/stereo/complete.oga" if system == "Linux"
                     else "/System/Library/Sounds/Glass.aiff")
    if sound is not None and not sound.is_file():
        raise ValueError(f"Sound not found: {sound}. On Ubuntu install pulseaudio-utils and "
                         "yaru-theme-sound, or pass --sound /path/to/audio")
    if system == "Linux" and not any(shutil.which(p) for p in ("paplay", "pw-play", "ffplay", "mpv", "play", "aplay")):
        raise ValueError("No audio player found. On Ubuntu install pulseaudio-utils.")
    source = peon_source(data)
    if sound is not None:
        sounds = pack / "sounds"
        sounds.mkdir(parents=True, exist_ok=True)
        destination = sounds / ("complete" + sound.suffix)
        if sound.resolve() != destination.resolve():
            shutil.copyfile(sound, destination)
        manifest = {"cesp_version": "1.0", "name": "local-chime", "display_name": "Local completion chime",
                    "version": "1.0.0", "categories": {"task.complete": {"sounds": [
                        {"file": "sounds/" + destination.name, "label": "Completion chime"}]}}}
        (pack / "openpeon.json").write_text(json.dumps(manifest, indent=2) + "\n")
    settings.setdefault("volume", 35000 / 65536)
    if volume is not None:
        settings["volume"] = volume / 65536
    settings.update({"default_pack": "local-chime", "enabled": True, "desktop_notifications": False})
    if system == "Linux" and shutil.which("paplay"):
        settings.setdefault("linux_audio_player", "paplay")
    config_file.write_text(json.dumps(settings, indent=2) + "\n")
    for name in ("scripts", "adapters", "peon.sh"):
        link(source / name, config / name, state)
    print(f"Configured local chime in {config}; no automatic notification hooks installed")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--with-chime", action="store_true", help="Install the pinned peon-ping source and a local sound pack")
    parser.add_argument("--home", type=Path, help="Use an alternate home directory for isolated setup/testing")
    parser.add_argument("--sound", type=Path, help="Local sound file (requires --with-chime)")
    parser.add_argument("--volume", type=int, help="PulseAudio-equivalent volume, 0–65536 (requires --with-chime)")
    args = parser.parse_args()
    if (args.sound is not None or args.volume is not None) and not args.with_chime:
        parser.error("--sound and --volume require --with-chime")
    if args.volume is not None and not 0 <= args.volume <= 65536:
        parser.error("--volume must be between 0 and 65536")
    home = (args.home or Path.home()).expanduser().resolve()
    def directory(variable, default):
        return Path(os.environ.get(variable, str(default))).expanduser() if args.home is None else default
    codex_home = directory("CODEX_HOME", home / ".codex")
    data = directory("XDG_DATA_HOME", home / ".local/share") / "setup_my_environment"
    config = directory("XDG_CONFIG_HOME", home / ".config") / "setup_my_environment/peon-ping"
    state = directory("XDG_STATE_HOME", home / ".local/state") / "setup_my_environment/backups"
    # Verify/install the optional backend before replacing a working legacy skill.
    if args.with_chime:
        install_chime(data, config, state, args.sound.expanduser() if args.sound else None, args.volume)
    codex_home.mkdir(parents=True, exist_ok=True)
    install_instructions(codex_home, state)
    config_target = codex_home / "config.toml"
    if not config_target.exists() and not config_target.is_symlink():
        shutil.copyfile(REPO / "codex/config.template.toml", config_target)
        print(f"Created {config_target}")
    skills = home / ".agents/skills"
    for skill in sorted((REPO / "codex/skills").iterdir()):
        if not (skill / "SKILL.md").is_file():
            continue
        link(skill, skills / skill.name, state)
        legacy = codex_home / "skills" / skill.name
        if legacy.exists() or legacy.is_symlink():
            backup(legacy, state)
    print("Shared Codex setup installed. Start a new Codex session to use it.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(str(error))
