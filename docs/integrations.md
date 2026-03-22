---
summary: "Explains how to connect abc-notify to Claude Code hooks and Codex notify settings."
read_when:
  - "Connecting abc-notify to Claude Code"
  - "Adding abc-notify to the Codex notify array"
---

# Integrations

## Claude Code

Register:

```bash
abc-notify setup claude
```

Remove:

```bash
abc-notify remove claude
```

Config location:

- `~/.claude/settings.json`

Direct config example:

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

If `settings.json` already has other keys, merge these hook entries instead of replacing the whole file.

Hooks that are added:

- `SessionStart` -> `abc-notify init`
- `Stop` -> `abc-notify notify`
- `Notification` -> `abc-notify notify`
- `SessionEnd` -> `abc-notify cleanup`

Flow:

1. `init` stores terminal app and window information at session start
2. `notify` sends a notification for completion or approval-required events
3. Clicking the notification runs the generated `focus.sh`
4. `cleanup` removes temporary session state when the session ends and prunes stale session directories older than 5 days

Notification body behavior:

- `Stop` uses a preview of `last_assistant_message` when Claude includes it in the hook payload
- `Notification` also uses that preview when present
- if the assistant text is empty, abc-notify falls back to the fixed event message such as `Task completed` or `Approval required`

Skip conditions:

- `notify` does nothing when `NOTIFY_DISABLED=true`
- `notify` does nothing when the session is still inside the throttle window
- `notify` does nothing when the captured terminal window is already focused

Temporary state location:

- `/tmp/abc-notify/<session_id>/`

## Codex

Register:

```bash
abc-notify setup codex
```

Remove:

```bash
abc-notify remove codex
```

Config location:

- `~/.codex/config.toml`

Direct config example:

```toml
notify = ["abc-notify"]
```

If `config.toml` already has a `notify` array, add `"abc-notify"` to that existing array instead of replacing unrelated config.

Config change:

- Adds `abc-notify` to the `notify` array in `~/.codex/config.toml`
- If no `notify` array exists, it creates `notify = ["abc-notify"]`

Codex event mapping:

- `agent-turn-complete` -> `Task completed`
- `agent-turn-paused` -> `Approval required`

Notification body behavior:

- if the notify payload includes assistant text in a supported top-level field, abc-notify shows a short preview of that text
- if no assistant text is present, abc-notify keeps the fixed fallback message from the event mapping above

Codex mode accepts a JSON argument directly.
The `cwd` field is used to load project-local `.abc-notify.env` overrides when available.

Terminal detection notes:

- the shared config fallback still applies: if `TERMINAL_APP` is unset, abc-notify falls back to `TERM_PROGRAM` mapping
- Codex also has an extra app-activation detection layer for click handling and can infer a bundle ID from environment data such as `__CFBundleIdentifier`, `TERM_PROGRAM`, `tmux`, and terminal-specific variables

```bash
abc-notify '{"type":"agent-turn-complete","cwd":"/path/to/project","thread-id":"123"}'
```

Skip conditions:

- notifications are skipped when `NOTIFY_DISABLED=true`
- notifications are skipped when the same `thread-id` is still inside the throttle window
- notifications are skipped when one of the configured terminal apps is already frontmost

## Focus Restore Differences

Claude Code:

- Attempts to restore the exact window captured at session start
- Uses window ID and PID when the native helper is available
- Falls back to AppleScript app activation and best-effort window raising when it is not

Codex:

- Activates the detected terminal app or bundle when you click the notification
- Uses the configured `TERMINAL_APP` list when available, with extra Codex-specific bundle detection as a fallback
- Does not restore a per-session exact window like Claude Code does

## Native Helper

It is usually better to install `abc-notify-native` as well.

Building it is not enough by itself. `abc-notify` only uses the helper if it can find it in one of its search paths.

Build:

```bash
swift build -c release
```

Install example:

```bash
cp .build/release/abc-notify-native /usr/local/bin/
chmod +x /usr/local/bin/abc-notify-native
```

Search order:

1. Next to the `abc-notify` executable
2. `/usr/local/libexec/abc-notify-native`
3. `/opt/homebrew/libexec/abc-notify-native`

The simplest manual setup is to place `abc-notify-native` in the same directory as `abc-notify`.
