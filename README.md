# setup_my_environment

# Usage
## Setup Ubuntu
```bash
wget https://raw.githubusercontent.com/rkoyama1623/setup_my_environment/main/setup.sh -O setup.sh
bash setup.sh
```

## Setup Git
```
ssh -T git@github.com
cd $HOME
cp /path/to/setup_my_environment/dot-files/dot.gitconfig .gitconfig
```

## Setup Codex on multiple computers

Python 3 and Git are required. Install Codex and sign in on each computer separately.
On Ubuntu, install the audio player and default sound first:

```bash
sudo apt install python3 git pulseaudio-utils yaru-theme-sound
```

Then run from this checkout:

```bash
make codex
```

This runs the `codex-chime` dependency to configure peon-ping, installs shared
instructions in `~/.codex/AGENTS.md`, and links this repository's skills into
`~/.agents/skills`, which applies across projects. Future Codex setup components
can be added as dependencies of the same `codex` target.
Existing instructions outside the managed block are preserved, and an existing
`config.toml` is kept. New installations receive `codex/config.template.toml`.
Edit that template for portable defaults; existing computers need those changes
merged into their local config explicitly.

The template includes the source computer's model (`gpt-6.1-sol`), reasoning
effort (`medium`), approval policy (`never`), sandbox mode (`danger-full-access`),
and concurrent subagent limit (`8`). These approval and sandbox defaults allow
execution without approval prompts or filesystem sandbox restrictions.
Choose settings appropriate for the target computer before its first setup.
The model must be available to the account used on that computer.

The exported template deliberately excludes project paths and trust entries,
UI/onboarding state, credentials, MCP endpoints, and other machine-specific data.
It is an explicit selection of settings, not a copy of the source config.
The shared instructions in `codex/global-instructions.md` contain the existing
cross-project chime guidance. Other project instructions stay in their own repos.

Conflicting skill folders and previous instruction files are backed up under
`~/.local/state/setup_my_environment/backups`. A legacy skill with the same name
under `~/.codex/skills` is moved there to avoid duplicate discovery.
`CODEX_HOME` and the XDG data/config/state directories are respected.
Keep this checkout at the same path after setup because the skill links point to it.
After pulling shared instruction changes, rerun `make codex` and start a new session.

Only reviewed instructions, scripts, and templates belong in this repository.
Do not copy `~/.codex` into it: authentication, API keys, histories, sessions,
databases, caches, and per-computer paths stay on their own computer.

### Local chime with peon-ping

The chime is included in `make codex`. Its component target can also be run directly:

```bash
make codex-chime
```

On macOS, install Python 3 and Git, then run `make codex`. The default sound
is the system `Glass.aiff`. Native Windows is not supported by this helper.

Setup fetches the reviewed peon-ping commit in `codex/peon-ping.json` into
`~/.local/share/setup_my_environment/peon-ping`. It creates a local sound pack
and config in `~/.config/setup_my_environment/peon-ping`; no audio files are
distributed here. No upstream installer, background watcher, or automatic
notification hooks are run. Review and update the pinned commit to upgrade.

To set a different sound or volume on one computer:

```bash
python3 scripts/setup_codex.py --with-chime --sound /path/to/sound.oga --volume 20000
```

The default volume is `35000` on the PulseAudio scale (peon-ping `0.5340576171875`).
Rerunning setup preserves the existing sound and volume unless explicitly changed.
Playback requires access to the computer's audio session, including over SSH.
The setup command does not play the sound. For instructions and skills without
the audio dependency, run `python3 scripts/setup_codex.py` directly.

In a new Codex session, ask “Use local-chime to play a chime”, or test directly:

```bash
bash codex/skills/local-chime/scripts/chime.sh
```

Common instructions decide when to use the skill; peon-ping handles playback;
the sound and volume are configured per computer. External OSS stays upstream
rather than being copied into this repository.

References: [Codex skills](https://learn.chatgpt.com/docs/build-skills),
[global instructions](https://learn.chatgpt.com/docs/agent-configuration/agents-md),
[configuration](https://learn.chatgpt.com/docs/config-file/config-basic),
[peon-ping](https://github.com/PeonPing/peon-ping).

To run the isolated setup checks without changing your home directory:

```bash
python3 -m unittest discover -s tests -v
```

