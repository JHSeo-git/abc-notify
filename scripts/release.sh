#!/usr/bin/env bash
set -euo pipefail

ROOT="${RELEASE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
VERSION_FILE="${ROOT}/VERSION"
CHANGELOG_FILE="${ROOT}/CHANGELOG.md"
DEFAULT_BRANCH="${RELEASE_BRANCH:-main}"

err() {
  echo "Error: $*" >&2
  exit 1
}

read_version() {
  [[ -f "$VERSION_FILE" ]] || err "Missing VERSION file at $VERSION_FILE"

  local version
  version="$(tr -d '\r\n' < "$VERSION_FILE")"
  [[ -n "$version" ]] || err "VERSION file is empty"

  printf '%s\n' "$version"
}

validate_version_format() {
  local version="$1"
  [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
    err "VERSION must match vX.Y.Z, got: $version"
  }
}

ensure_release_branch() {
  local branch="$1"
  [[ "${ALLOW_NON_MAIN_RELEASE:-0}" == "1" ]] && return 0
  [[ "$branch" == "$DEFAULT_BRANCH" ]] || err "Release must run from ${DEFAULT_BRANCH}; current branch: $branch"
}

ensure_gh_authenticated() {
  gh auth status >/dev/null 2>&1 || err "gh auth status failed; authenticate GitHub CLI first"
}

ensure_clean_worktree() {
  git diff --quiet || err "Worktree has unstaged changes"
  git diff --cached --quiet || err "Worktree has staged but uncommitted changes"
  [[ -z "$(git ls-files --others --exclude-standard)" ]] || err "Worktree has untracked files"
}

ensure_changelog_has_version() {
  local version="$1"
  [[ -f "$CHANGELOG_FILE" ]] || err "Missing CHANGELOG.md"
  grep -Eq "^## ${version}( |$|-)" "$CHANGELOG_FILE" || err "CHANGELOG.md missing section for ${version}"
}

ensure_changelog_current_version_first() {
  local version="$1"
  ensure_changelog_has_version "$version"

  local first_release_heading
  first_release_heading="$(grep -E '^## v[0-9]+\.[0-9]+\.[0-9]+( |$|-)' "$CHANGELOG_FILE" | head -n 1 || true)"
  [[ -n "$first_release_heading" ]] || err "CHANGELOG.md has no release headings"
  [[ "$first_release_heading" =~ ^##[[:space:]]${version}( |$|-) ]] || {
    err "CHANGELOG.md top release section must be ${version}; found: ${first_release_heading#\#\# }"
  }
}

extract_notes_from_changelog() {
  local version="$1"
  ensure_changelog_has_version "$version"

  awk -v version="$version" '
    $0 ~ "^## " version "($|[ -])" {capture=1; next}
    capture && /^## / {exit}
    capture {print}
  ' "$CHANGELOG_FILE" | sed '/^[[:space:]]*$/d'
}

ensure_notes_present() {
  local version="$1"
  local notes
  notes="$(extract_notes_from_changelog "$version")"
  [[ -n "$notes" ]] || err "CHANGELOG.md section for ${version} has no release notes"
}

ensure_tag_absent() {
  local tag="$1"
  git rev-parse -q --verify "refs/tags/${tag}" >/dev/null 2>&1 && err "Local tag already exists: $tag"
  git ls-remote --exit-code --tags origin "refs/tags/${tag}" >/dev/null 2>&1 && err "Remote tag already exists: $tag"
}

ensure_release_absent() {
  local tag="$1"
  gh release view "$tag" >/dev/null 2>&1 && err "GitHub release already exists: $tag"
}

run_release_gate() {
  swift test --parallel
  bats Tests/bash/
  bun run docs:list
  swift build -c release --product abc-notify-native
}

create_release_notes_file() {
  local version="$1"
  local notes_file
  notes_file="$(mktemp /tmp/abc-notify-release-notes.XXXXXX.md)"
  extract_notes_from_changelog "$version" > "$notes_file"
  printf '%s\n' "$notes_file"
}

create_tag() {
  local tag="$1"
  git tag -a "$tag" -m "abc-notify ${tag}"
}

push_release_refs() {
  local branch="$1"
  local tag="$2"
  git push origin "$branch"
  git push origin "$tag"
}

create_github_release() {
  local tag="$1"
  local notes_file="$2"
  gh release create "$tag" \
    --verify-tag \
    --title "abc-notify ${tag}" \
    --notes-file "$notes_file"
}

main() {
  cd "$ROOT"

  command -v git >/dev/null 2>&1 || err "git is required"
  command -v gh >/dev/null 2>&1 || err "gh is required"
  command -v swift >/dev/null 2>&1 || err "swift is required"
  command -v bats >/dev/null 2>&1 || err "bats is required"
  command -v bun >/dev/null 2>&1 || err "bun is required"

  local branch
  branch="$(git branch --show-current)"
  [[ -n "$branch" ]] || err "Could not determine current git branch"

  local version
  version="$(read_version)"

  validate_version_format "$version"
  ensure_release_branch "$branch"
  ensure_gh_authenticated
  ensure_clean_worktree
  ensure_changelog_has_version "$version"
  ensure_changelog_current_version_first "$version"
  ensure_notes_present "$version"
  ensure_tag_absent "$version"
  ensure_release_absent "$version"

  run_release_gate

  local notes_file
  notes_file="$(create_release_notes_file "$version")"
  trap 'rm -f "$notes_file"' EXIT

  create_tag "$version"
  push_release_refs "$branch" "$version"
  create_github_release "$version" "$notes_file"

  echo "Release ${version} created."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
