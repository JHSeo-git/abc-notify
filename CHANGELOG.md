# Changelog

All notable changes to this project will be documented in this file.

Format:

- Release headings use `## vX.Y.Z - YYYY-MM-DD`
- The local release script extracts notes from the matching version section

## v0.2.0 - 2026-03-20
- Added notification body previews that show the last assistant message for Claude Code and Codex when available.
- Preserved the existing fixed fallback messages when assistant text is missing from the notify payload.
- Added Bash regression coverage for preview normalization, truncation, and fallback behavior.

## v0.1.1 - 2026-03-20
- Improved Codex notification click activation by adding more reliable terminal bundle detection.
- Fixed WezTerm bundle id handling and added VSCode and Warp activation mappings.
- Added regression coverage for Codex terminal bundle detection paths.

## v0.1.0 - 2026-03-20
- Initial public release of `abc-notify`.
- Added universal GitHub release packaging for `abc-notify-native`.
- Added a local `scripts/release.sh` release flow.
