---
name: local-chime
description: Play a local chime with peon-ping on Linux or macOS when the user asks to ring, test, or signal completion with sound.
---

# Local Chime

Run `scripts/chime.sh` relative to this skill's directory:

```bash
bash <skill-directory>/scripts/chime.sh
```

The helper uses peon-ping's `preview task.complete` command and this computer's
configuration at `${XDG_CONFIG_HOME:-$HOME/.config}/setup_my_environment/peon-ping/config.json`.
The default PulseAudio-equivalent volume is `35000` (peon-ping volume `0.5340576171875`).
Linux defaults to Yaru's completion sound; macOS defaults to the system Glass sound.

If setup is missing, run `make codex-chime` from the `setup_my_environment` checkout.
To change the sound or volume, run its `scripts/setup_codex.py --with-chime`
with `--sound /path/to/audio` or `--volume 20000` for a quieter sound.
Larger volume values require care; the supported range is 0–65536.

Playback is best-effort: a successful preview command does not prove that the
sound was audible. Playback needs access to the local audio session.
Do not change system-wide volume or install
automatic notification hooks just to play a chime.
