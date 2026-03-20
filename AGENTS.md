# Repository Guidelines

## Project Structure & Module Organization

This repository ships a macOS notification helper for AI CLIs. The shell entrypoint lives at `bin/abc-notify`. Native window-focus logic lives in `Sources/abc-notify-native/` with focused Swift files such as `WindowFocus.swift` and `WindowCapture.swift`. Swift package settings are in `Package.swift`. Installer scripts live in `scripts/`, Homebrew packaging in `Formula/abc-notify.rb`, and release automation in `.github/workflows/release.yml`. User-facing configuration starts from `.abc-notify.env.example`.

## Build, Test, and Development Commands

- `swift build`: build the native helper in debug mode.
- `swift build -c release`: build the release binary used by packaging and CI.
- `swift test`: run Swift Package tests. There is no test target yet, so add one with new behavior changes.
- `.build/debug/abc-notify-native help`: smoke-test the native CLI after Swift changes.
- `bin/abc-notify doctor`: verify local dependencies, hook setup, and writable temp paths.

For install flow changes, also sanity-check `scripts/install.sh` and `scripts/uninstall.sh` on macOS.

## Coding Style & Naming Conventions

Use Swift 5.9 style with 4-space indentation and small, single-purpose files. Keep command dispatch readable and push platform-specific logic into helper types/files. Use `UpperCamelCase` for types, `lowerCamelCase` for functions and properties, and clear verb-based names such as `captureTerminalWindow()`. Shell scripts should keep `bash` + `set -euo pipefail`; prefer kebab-case file names.

## Testing Guidelines

- `swift test`: run Swift unit tests (covers ABCNotifyLib: utilities, process tree, window capture/focus, accessibility)
- `bats tests/bash/`: run Bash tests (requires bats-core; covers mappings, parsing, throttle, config, session, setup, commands)

Add Swift tests under `Tests/ABCNotifyTests/` when behavior changes. Name files `<Feature>Tests.swift` and methods like `testFocusFailsWithoutWindowID()`. Add Bash tests under `tests/bash/` as `.bats` files. For notification or accessibility changes that are hard to automate, document the manual macOS check in the PR and run `bin/abc-notify doctor`.

## Commit & Pull Request Guidelines

The published history is minimal, but use Conventional Commits going forward: `feat:`, `fix:`, `docs:`, `chore:`. Keep PRs narrow. Include:

- a short problem/solution summary
- linked issue or context
- exact validation commands run
- screenshots or terminal output when notification UX changes

If a change affects releases, update `bin/abc-notify`, `Formula/abc-notify.rb`, and any matching README instructions together.

## Security & Configuration Tips

Do not commit personal values from `~/.abc-notify.env`. Test with the sample file first. macOS accessibility and notification permissions are part of runtime behavior, so call out any permission-model changes explicitly in docs and PR notes.
