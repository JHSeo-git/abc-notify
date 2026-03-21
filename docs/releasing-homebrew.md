---
summary: "abc-notify Homebrew release steps across the app repo and separate tap repo, including asset publishing, tap verification, and manual Formula recovery."
read_when:
  - "Publishing an abc-notify release that must stay installable via Homebrew"
  - "Checking how the separate homebrew-tap Formula should follow an abc-notify GitHub release"
  - "Verifying or manually fixing the Homebrew tap Formula after publishing release assets"
---

# Homebrew Release Playbook

Homebrew for `abc-notify` is managed in the separate tap repo `JHSeo-git/homebrew-tap`.
This repository owns the app source, release tags, and GitHub release assets.
The tap repo owns the installable Formula that Homebrew users actually consume.

## Prereqs

- Homebrew installed on macOS
- `gh auth status` already working
- Release operator access to push `main` in this repo and in `JHSeo-git/homebrew-tap`
- A normal release plan ready from [RELEASING.md](RELEASING.md)

## 1) Release `abc-notify` normally

Follow [RELEASING.md](RELEASING.md):

```sh
./scripts/release.sh
```

That script is the source of truth for the release.
It validates `VERSION` and `CHANGELOG.md`, pushes `main`, pushes the release tag, and creates the GitHub release.

## 2) Run the release workflow to publish the native asset

After the GitHub release exists, run the release workflow:

```sh
gh workflow run release.yml -f tag="$(cat VERSION)"
```

Then verify the workflow run and the uploaded asset:

```sh
gh run list -R JHSeo-git/abc-notify --workflow release.yml --limit 5
gh run view <run-id> -R JHSeo-git/abc-notify
gh release view "$(cat VERSION)" -R JHSeo-git/abc-notify --json assets
```

What you want:

- the release workflow is green
- the GitHub release has an `abc-notify-native` asset

## 3) Update the separate tap Formula

Today the Homebrew Formula lives in `~/Projects/homebrew-tap` / `https://github.com/JHSeo-git/homebrew-tap`.
Do not assume `Formula/abc-notify.rb` in this repository is what `brew tap JHSeo-git/tap` installs.

For a stable Formula, update the tap repo's `Formula/abc-notify.rb` so it matches the current release model you want to ship.

At minimum, verify the tap repo state:

```sh
cd ~/Projects/homebrew-tap
git pull --rebase origin main
sed -n '1,220p' Formula/abc-notify.rb
```

If the tap Formula is still `head`-only, Homebrew users will need `brew install --HEAD abc-notify`.
If you want plain `brew install abc-notify`, convert the tap Formula to a stable release-based install first.

## 4) Verify Homebrew install

Use a clean local install path:

```sh
brew untap JHSeo-git/tap || true
brew tap JHSeo-git/tap
brew uninstall abc-notify || true
brew install abc-notify
abc-notify version
abc-notify doctor
```

If the tap is intentionally still `head`-only, verify that flow explicitly instead:

```sh
brew uninstall abc-notify || true
brew install --HEAD abc-notify
abc-notify version
```

What you want:

- if the tap is stable, `brew install abc-notify` succeeds
- if the tap is `head`-only, `brew install --HEAD abc-notify` succeeds
- `abc-notify version` matches the release version
- `abc-notify doctor` reports a sane setup state for the current machine

If you changed install behavior, also run a quick setup smoke test:

```sh
abc-notify setup codex
abc-notify remove codex
```

## 5) Manual recovery for the tap Formula

Only do this if the tap Formula still does not match the release state you want to publish.

The exact edit depends on whether the tap stays source-built or moves to a release-asset install model.

If you need the source tarball checksum for a stable source Formula:

```sh
TAG="v0.2.0"
curl -fsSL "https://github.com/JHSeo-git/abc-notify/archive/refs/tags/${TAG}.tar.gz" -o "/tmp/abc-notify-${TAG}.tar.gz"
shasum -a 256 "/tmp/abc-notify-${TAG}.tar.gz"
```

If you need the uploaded native asset checksum:

```sh
TAG="v0.2.0"
curl -fsSL "https://github.com/JHSeo-git/abc-notify/releases/download/${TAG}/abc-notify-native" -o "/tmp/abc-notify-native-${TAG}"
shasum -a 256 "/tmp/abc-notify-native-${TAG}"
```

After editing the tap Formula, verify install again:

```sh
cd ~/Projects/homebrew-tap
brew uninstall abc-notify || true
brew install abc-notify
abc-notify version
```

Commit only the Formula file with the normal helper:

```sh
cd ~/Projects/homebrew-tap
./scripts/committer "chore: update Formula sha256 for ${TAG}" Formula/abc-notify.rb
git push origin main
```

## Notes

- This repo and the tap repo have different responsibilities. Keep them separate in release notes and operator docs.
- The release workflow here currently publishes assets only. It does not push tap Formula changes.
- If the tap stays `head`-only, document that clearly for users instead of implying stable `brew install abc-notify`.
