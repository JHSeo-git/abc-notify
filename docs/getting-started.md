---
summary: "Quick start guide for installing abc-notify on macOS and connecting it to Claude Code and Codex."
read_when:
  - "Installing abc-notify for the first time"
  - "Setting it up and running doctor for the first time"
---

# Getting Started

## Requirements

- macOS
- `terminal-notifier`
- `jq`
- Optional: Swift toolchain, for building `abc-notify-native`

Install the base dependencies:

```bash
brew install terminal-notifier jq
```

## Install

### Homebrew

```bash
brew tap JHSeo-git/tap
brew install abc-notify
```

Notes:

- The tap Formula installs the release archive and includes `abc-notify-native`.
- You do not need a local Swift toolchain for the Homebrew path.

### Manual Install

```bash
git clone https://github.com/JHSeo-git/abc-notify.git
cd abc-notify
bash scripts/manual-install.sh
```

This script builds the release helper from the local checkout, installs `abc-notify` and `abc-notify-native`, then runs `setup all` and `doctor`.
To remove that checkout-based install later, run `bash scripts/manual-uninstall.sh` from the same repository.

## Register Hooks

Register both:

```bash
abc-notify setup all
```

Register individually:

```bash
abc-notify setup claude
abc-notify setup codex
```

If you prefer to edit the config files directly, use these minimal examples.
Keep any unrelated existing settings and merge the snippets instead of replacing the whole file.

Claude Code `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "abc-notify init" }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "abc-notify notify" }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "abc-notify notify" }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "abc-notify cleanup" }
        ]
      }
    ]
  }
}
```

Codex `~/.codex/config.toml`:

```toml
notify = ["abc-notify"]
```

## Verify

```bash
abc-notify doctor
```

Example successful output:

```text
[✓] macOS detected
[✓] terminal-notifier installed
[✓] jq installed
[✓] Claude Code hooks registered
[✓] Codex notify configured
```

## First Config

Copy the example config:

```bash
cp .abc-notify.env.example ~/.abc-notify.env
```

If you need project-specific overrides, add `.abc-notify.env` in your working directory.

## Related Docs

- [CLI Reference](cli.md)
- [Configuration](configuration.md)
- [Integrations](integrations.md)
- [Troubleshooting](troubleshooting.md)
