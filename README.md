# abc-notify

Desktop notifications for AI CLI tools on macOS.
It sends alerts for Claude Code and Codex events, and can bring focus back to your terminal when you click the notification.
Exact window restore for Claude Code requires `abc-notify-native`. Codex restores app focus.

## Quick Start

```bash
brew tap JHSeo-git/abc-notify
brew install abc-notify
abc-notify setup all
abc-notify doctor
```

## Docs

For full install steps, manual setup, native helper install, and config details:

For users:

- [Getting Started](docs/getting-started.md)
- [CLI Reference](docs/cli.md)
- [Configuration](docs/configuration.md)
- [Integrations](docs/integrations.md)
- [Troubleshooting](docs/troubleshooting.md)

For developers:

- [Development](docs/development.md)

## Common Commands

```text
abc-notify setup [claude|codex|all]
abc-notify remove [claude|codex|all]
abc-notify doctor
abc-notify version
abc-notify help
```

For hook commands, native helper commands, and Codex JSON mode:

- [CLI Reference](docs/cli.md)

## Supported Tools

| Tool        | Events                           | Focus Restore                                             |
| ----------- | -------------------------------- | --------------------------------------------------------- |
| Claude Code | Task complete, Approval required | Exact window with native helper, otherwise fallback focus |
| Codex CLI   | Task complete, Approval required | App activation                                            |

## License

[MIT](LICENSE)
