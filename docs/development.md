---
summary: "Covers repository layout, local development flow, and build and verification commands for abc-notify."
read_when:
  - "Modifying abc-notify or adding new behavior"
  - "Understanding the boundary between the shell script and the Swift native helper"
---

# Development

## Repository Layout

- `bin/abc-notify`: main Bash entrypoint
- `Sources/abc-notify-native/`: native window capture and focus logic
- `Package.swift`: Swift package configuration
- `scripts/install.sh`: installer script
- `scripts/uninstall.sh`: uninstall script
- `scripts/docs-list.ts`: lists `docs/` files and metadata
- `scripts/committer`: helper that stages only selected paths before commit
- `docs/releasing-homebrew.md`: Homebrew tap release and verification guide

## Key Runtime Split

Shell layer:

- config loading
- Claude/Codex integration
- notification delivery
- setup/remove/doctor commands

Swift native layer:

- current terminal window capture
- focus restore
- focus detection
- Accessibility permission checks

If the native helper is not installed, the shell layer falls back to AppleScript.

## Build

Debug build:

```bash
swift build
```

Release build:

```bash
swift build -c release
```

Native helper smoke test:

```bash
.build/debug/abc-notify-native help
```

## Test And Verify

Baseline verification for this repository:

```bash
swift test
bun run docs:list
bin/abc-notify help
```

macOS runtime check:

```bash
bin/abc-notify doctor
```

If you changed the install or uninstall flow, check these too:

```bash
scripts/install.sh
scripts/uninstall.sh
```

## Dev Homebrew Link

For local verification only:

```bash
swift build -c release
sudo ./scripts/dev-link-homebrew.sh link
abc-notify doctor
sudo ./scripts/dev-link-homebrew.sh unlink
```

This script links the current workspace into `$(brew --prefix)/bin`.
It does not replace tap-based install testing.
It refuses to overwrite non-symlink files in the Homebrew prefix.

## Release Flow

For release operator steps, see [RELEASING.md](RELEASING.md).
The local `scripts/release.sh` script validates the release inputs, pushes the release tag, and creates the GitHub release from `CHANGELOG.md`.

## Docs Workflow

When adding docs:

1. Add front matter `summary` to `docs/*.md`
2. Add `read_when` when it helps discovery
3. Run `bun run docs:list` to confirm output

## Implementation Notes

- Duplicate notification throttling is handled with files under `/tmp/abc-notify`
- Claude session state lives under `/tmp/abc-notify/<session_id>/`
- Codex uses a `thread-id`-based throttle key
- It is useful to keep `doctor` output aligned with the user-facing docs
