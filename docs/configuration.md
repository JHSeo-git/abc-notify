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

In Codex mode, abc-notify looks for a running terminal from this list and activates it when you click the notification.

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

If `TERMINAL_APP` is not set, abc-notify maps `TERM_PROGRAM` to these app names:

- `iTerm.app` / `iTerm2` -> `iTerm2`
- `Apple_Terminal` -> `Terminal`
- `WezTerm` -> `WezTerm`
- `Alacritty` -> `Alacritty`
- `kitty` -> `kitty`
- `Hyper` -> `Hyper`
- `ghostty` -> `Ghostty`

If accurate focus restore matters, it is safer to set `TERMINAL_APP` explicitly.
