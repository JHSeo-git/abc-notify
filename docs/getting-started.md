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
brew install --HEAD abc-notify
```

Notes:

- The current tap Formula is `head`-only, so `brew install abc-notify` does not work yet.
- The Homebrew install path builds and installs `abc-notify-native` as part of the formula.

### Script Install

```bash
curl -fsSL https://raw.githubusercontent.com/JHSeo-git/abc-notify/main/scripts/install.sh | bash
```

Notes:

- This installer requires macOS and Homebrew.
- If `terminal-notifier` or `jq` is missing, the script installs them with Homebrew first.
- It installs the `abc-notify` shell binary to `/usr/local/bin/abc-notify` and `VERSION` to `/usr/local/share/abc-notify/VERSION`.
- It runs `abc-notify setup all` and `abc-notify doctor` automatically at the end.
- When run directly from the raw GitHub URL, the script does not have the full repository checkout, so it usually cannot build and install `abc-notify-native`.
- In that mode, abc-notify uses the AppleScript fallback until you install the native helper separately.
- If you want more reliable window focus restore, prefer the Homebrew path or the manual install below with the native helper.

### Manual Install

```bash
git clone https://github.com/JHSeo-git/abc-notify.git
cd abc-notify
swift build -c release
cp bin/abc-notify /usr/local/bin/
cp .build/release/abc-notify-native /usr/local/bin/
mkdir -p /usr/local/share/abc-notify
cp VERSION /usr/local/share/abc-notify/VERSION
chmod +x /usr/local/bin/abc-notify
chmod +x /usr/local/bin/abc-notify-native
```

abc-notify can still work without the native helper, but it will be limited to the AppleScript fallback path.

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
