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

Config change:

- Adds `abc-notify` to the `notify` array in `~/.codex/config.toml`
- If no `notify` array exists, it creates `notify = ["abc-notify"]`

Codex event mapping:

- `agent-turn-complete` -> `Task completed`
- `agent-turn-paused` -> `Approval required`

Codex mode accepts a JSON argument directly.
The `cwd` field is used to load project-local `.abc-notify.env` overrides when available.

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

- Looks for a running terminal app from the configured list and activates it
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
