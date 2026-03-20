---
summary: "Covers common notification, permission, focus, and dependency issues after installing abc-notify."
read_when:
  - "Notifications are not appearing"
  - "Clicking a notification does not return focus to the terminal"
  - "doctor reports failed checks"
---

# Troubleshooting

## Start With Doctor

Start with:

```bash
abc-notify doctor
```

This command checks:

- whether you are on macOS
- `terminal-notifier`
- `jq`
- Claude Code hook registration
- Codex notify configuration
- native helper install state and Accessibility permission
- whether `/tmp/abc-notify` is writable

## Notifications Do Not Appear

Check:

- whether `terminal-notifier` is installed
- whether macOS notifications allow `terminal-notifier`
- whether `NOTIFY_DISABLED=true`
- whether the same session or thread is being throttled
- whether abc-notify intentionally skipped the notification because your terminal was already focused

Fix:

```bash
brew install terminal-notifier jq
abc-notify doctor
```

## Click Does Not Return Focus

Possible causes:

- `TERMINAL_APP` is set incorrectly
- the native helper is missing
- Accessibility permission has not been granted
- you are in Codex mode, which only activates the app instead of restoring an exact Claude session window
- you installed with the raw script path and never installed `abc-notify-native` separately

Recommended steps:

```bash
swift build -c release
cp .build/release/abc-notify-native /usr/local/bin/
chmod +x /usr/local/bin/abc-notify-native
abc-notify check-access --prompt
```

Then set `TERMINAL_APP` explicitly.

```bash
TERMINAL_APP=iTerm2
```

You can also provide a comma-separated list:

```bash
TERMINAL_APP=iTerm2,Terminal,WezTerm
```

## Claude Hook Not Working

Re-register:

```bash
abc-notify remove claude
abc-notify setup claude
```

Check this file:

- `~/.claude/settings.json`

It should contain entries for `abc-notify init`, `abc-notify notify`, and `abc-notify cleanup`.
Those entries are registered under `SessionStart`, `Stop`, `Notification`, and `SessionEnd`.

## Codex Notify Not Working

Re-register:

```bash
abc-notify remove codex
abc-notify setup codex
```

Check this file:

- `~/.codex/config.toml`

It should contain `notify = ["abc-notify"]` or include `"abc-notify"` in an existing notify array.
If your project needs different terminal preferences, check whether `cwd`-specific `.abc-notify.env` overrides are being loaded.

## Temp Directory Problems

Session data is stored under:

- `/tmp/abc-notify`

If `doctor` reports a writable error, check permissions and the state of `/tmp` first.

## AppleScript Fallback

abc-notify can still work without the native helper, but:

- exact window restore is less reliable
- Claude Code uses AppleScript activation and best-effort window raising
- Codex still uses app activation, not per-session exact window restore
- focus quality may vary by terminal app

If accurate window focus matters, install the native helper.
