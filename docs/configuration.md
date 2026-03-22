---
summary: "Explains global configuration, per-project overrides, and config priority for abc-notify."
read_when:
  - "Changing notification titles, sounds, terminal apps, or throttle values"
  - "Adding per-project config overrides"
---

# Configuration

## Config Files

`abc-notify` loads configuration from two locations.

- Global: `~/.abc-notify.env`
- Per-project: `./.abc-notify.env`

Priority:

1. `./.abc-notify.env`
2. `~/.abc-notify.env`
3. Internal fallbacks, including `TERM_PROGRAM`-based detection

## Example

```bash
cp .abc-notify.env.example ~/.abc-notify.env
```

Per-project override:

```bash
cp .abc-notify.env.example /path/to/project/.abc-notify.env
```

## Variables

### `TERMINAL_APP`

You can provide multiple apps as a comma-separated list.

Example:

```bash
TERMINAL_APP=iTerm2,Terminal,WezTerm
```

If this is set, abc-notify uses it as the preferred terminal-app list for focus detection and activation.

- Claude Code uses it as a fallback when exact window capture is unavailable.
- Codex uses it for frontmost-app checks and as a fallback for click-to-activate behavior.

### `NOTIFY_SOUND`

The macOS system sound name.

```bash
NOTIFY_SOUND=Glass
```

### `NOTIFY_THROTTLE`

Minimum interval between duplicate notifications, in seconds.

```bash
NOTIFY_THROTTLE=2
```

### `NOTIFY_DISABLED`

Disables all notifications.

```bash
NOTIFY_DISABLED=false
```

### `NOTIFY_TITLE_CLAUDE`

Notification title for Claude Code.

```bash
NOTIFY_TITLE_CLAUDE="Claude Code"
```

### `NOTIFY_TITLE_CODEX`

Notification title for Codex.

```bash
NOTIFY_TITLE_CODEX="Codex"
```

## Terminal Detection

If `TERMINAL_APP` is not set, abc-notify falls back to a shared `TERM_PROGRAM` mapping for terminal app names:

- `iTerm.app` / `iTerm2` -> `iTerm2`
- `Apple_Terminal` -> `Terminal`
- `WezTerm` -> `WezTerm`
- `Alacritty` -> `Alacritty`
- `kitty` -> `kitty`
- `Hyper` -> `Hyper`
- `ghostty` -> `Ghostty`

This fallback is not Codex-only. Claude Code and Codex both use it when `TERMINAL_APP` is unset.

Codex also has an extra click-activation detection layer that can infer a bundle ID from environment data such as `__CFBundleIdentifier`, `TERM_PROGRAM`, `tmux`, and terminal-specific variables. That extra detection is specific to Codex app activation and does not change the shared config fallback above.

If accurate focus restore matters, it is safer to set `TERMINAL_APP` explicitly. Claude Code can restore an exact session window when capture data is available, while Codex still restores app focus only.
