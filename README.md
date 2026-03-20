# abc-notify

Desktop notifications for AI CLI tools on macOS.
It sends alerts for Claude Code and Codex events, and can bring you back to your terminal when you click the notification.

## Quick Start

```bash
brew tap JHSeo-git/abc-notify
brew install abc-notify
abc-notify setup all
abc-notify doctor
```

For full install steps, manual setup, and native helper details:
- [docs/getting-started.md](docs/getting-started.md)

## Docs

For users:
- [Getting Started](docs/getting-started.md)
- [CLI Reference](docs/cli.md)
- [Configuration](docs/configuration.md)
- [Integrations](docs/integrations.md)
- [Troubleshooting](docs/troubleshooting.md)

For developers:
- [Development](docs/development.md)

## Commands

```text
abc-notify setup [claude|codex|all]
abc-notify remove [claude|codex|all]
abc-notify doctor
abc-notify version
abc-notify help
```

## Supported Tools

| Tool | Events | Focus Restore |
|------|--------|---------------|
| Claude Code | Task complete, Approval required | Exact window |
| Codex CLI | Task complete, Approval required | App activation |

## License

[MIT](LICENSE)
