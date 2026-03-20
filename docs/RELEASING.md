---
summary: "abc-notify release checklist: validate VERSION and CHANGELOG, tag the release, and publish GitHub release notes."
read_when:
  - "Cutting a new abc-notify release"
  - "Updating VERSION or CHANGELOG.md for a release"
  - "Checking how the local release script, VERSION, and CHANGELOG.md fit together"
---

# Release Process

This repository uses a local release flow centered on `scripts/release.sh`.
The script validates the release inputs, creates the git tag, pushes `main` and the tag, and creates the GitHub release from `CHANGELOG.md`.

## Expectations

When someone says "release abc-notify", the release is not finished until all of these are true:

- `VERSION` and `CHANGELOG.md` match the target release
- the local release gate passes
- the GitHub release exists with the correct tag and notes

## Release Automation Notes (`scripts/release.sh`)

The local release script:

- requires a clean git worktree
- requires the current branch to be `main` unless `ALLOW_NON_MAIN_RELEASE=1` is set
- requires `gh auth status` to succeed before doing any git or release work
- requires `VERSION` to match `vX.Y.Z`
- requires `CHANGELOG.md` to contain a section for that exact version
- requires the top release section in `CHANGELOG.md` to match `VERSION`
- refuses to run if the git tag already exists locally or on `origin`
- refuses to run if the GitHub release already exists
- extracts the GitHub release notes directly from the matching `CHANGELOG.md` section
- pushes `main` first, then pushes the tag, then creates the GitHub release

The local release gate currently runs:

- `swift test --parallel`
- `bats Tests/bash/`
- `bun run docs:list`
- `swift build -c release --product abc-notify-native`

Required tools on `PATH`:

- `git`
- `gh`
- `swift`
- `bats`
- `bun`

## Prerequisites

- Work from `main`
- Clean git worktree
- `gh auth status` already authenticated
- `VERSION` updated to the target release, for example `v0.2.0`
- `CHANGELOG.md` contains a finalized section for that same version

## Version And Changelog Format

`VERSION` must contain a single `vX.Y.Z` string, for example:

```text
v0.2.0
```

`CHANGELOG.md` must include a matching heading like:

```md
## v0.2.0 - 2026-03-21
- Short user-facing change one.
- Short user-facing change two.
```

The release script publishes that section as the GitHub release notes, so keep it concise and user-facing.

## Release Command

Run:

```bash
./scripts/release.sh
```

What it does:

- reads and validates `VERSION`
- validates branch, git state, changelog, tag, and existing GitHub release state
- runs the local release gate
- creates an annotated git tag matching `VERSION`
- pushes `main`
- pushes the release tag
- creates the GitHub release using the changelog section as release notes

## Checklist

- [ ] Update `VERSION`
- [ ] Finalize the matching `CHANGELOG.md` section
- [ ] Ensure that matching version is the top release section in `CHANGELOG.md`
- [ ] Confirm `gh auth status`
- [ ] Confirm `git status --short` is clean
- [ ] Run `./scripts/release.sh`
- [ ] Confirm the GitHub release has the correct title, tag, and notes

## Manual Verification

After the script finishes:

1. Open the GitHub release page for the new tag.
2. Confirm the title matches `abc-notify vX.Y.Z`.
3. Confirm the release notes match the intended `CHANGELOG.md` section.
4. Confirm the published tag is the same string as `VERSION`.

## Troubleshooting

- If `scripts/release.sh` refuses to run, check branch, worktree, `VERSION`, and `CHANGELOG.md` first.
- If `gh release create` fails, confirm `gh auth status` first.
- If the release notes are wrong, fix the matching `CHANGELOG.md` section and rerun with a new version rather than rewriting an already-published release.
