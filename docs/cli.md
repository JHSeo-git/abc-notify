---
summary: "Reference for abc-notify CLI commands, hook commands, native helper commands, and Codex JSON mode."
read_when:
  - "Looking up abc-notify commands and arguments"
  - "Understanding internal hook commands or native helper commands"
---

# CLI Reference

## Overview

`abc-notify` provides a small command-line interface for setup, diagnostics, hook handling, and native window actions.

Basic usage:

```bash
abc-notify <command> [options]
```

## User Commands

### `setup [claude|codex|all]`

Registers abc-notify with Claude Code, Codex, or both.

Examples:

```bash
abc-notify setup all
abc-notify setup claude
abc-notify setup codex
```

### `remove [claude|codex|all]`

Removes the Claude Code hooks, the Codex notify config, or both.

Examples:

```bash
abc-notify remove all
abc-notify remove claude
abc-notify remove codex
```

### `doctor`

Checks dependencies, integration state, native helper availability, and writable temp paths.

Example:

```bash
abc-notify doctor
```

### `version`

Prints the current abc-notify version.

Example:

```bash
abc-notify version
```

### `help`

Prints the built-in help text.

Example:

```bash
abc-notify help
```

## Hook Commands

These commands are meant to be called by integrations, not by hand in normal usage.

### `init`

Used by the Claude Code `SessionStart` hook. Captures terminal window state and writes session metadata under `/tmp/abc-notify/<session_id>/`.

### `notify`

Used by Claude Code `Stop` and `Notification` hooks. Sends a desktop notification and attaches click behavior when possible.

### `cleanup`

Used by the Claude Code `SessionEnd` hook. Removes the current session state and clears stale session directories.

## Native Helper Commands

These commands require `abc-notify-native` to be installed in a discoverable location.

### `capture`

Captures the current terminal window as JSON.

```bash
abc-notify capture
```

### `focus --window-id <id> --pid <pid>`

Focuses a specific window.

```bash
abc-notify focus --window-id 123 --pid 456
```

### `is-focused --window-id <id> --pid <pid>`

Checks whether the target window is currently focused.

```bash
abc-notify is-focused --window-id 123 --pid 456
```

### `check-access [--prompt]`

Checks macOS Accessibility permission for the native helper. With `--prompt`, it requests permission if needed.

```bash
abc-notify check-access --prompt
```

## Codex JSON Mode

When Codex calls abc-notify as a notify handler, it passes a JSON object directly.

Example:

```bash
abc-notify '{"type":"agent-turn-complete","cwd":"/path/to/project","thread-id":"123"}'
```

Common event types:

- `agent-turn-complete`
- `agent-turn-paused`

## Config Files

abc-notify reads configuration from:

- `~/.abc-notify.env`
- `./.abc-notify.env`

Per-project config overrides the global file.
