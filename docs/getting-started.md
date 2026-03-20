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
brew tap JHSeo-git/abc-notify
brew install abc-notify
```

### Script Install

```bash
curl -fsSL https://raw.githubusercontent.com/JHSeo-git/abc-notify/main/scripts/install.sh | bash
```

Notes:

- This path installs the `abc-notify` shell binary and shared `VERSION` file.
- Running the raw script alone usually does not build and install `abc-notify-native`.
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
