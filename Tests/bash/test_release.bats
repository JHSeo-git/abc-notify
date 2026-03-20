#!/usr/bin/env bats

@test "release: read_version returns v-prefixed semver from VERSION" {
  local repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/scripts"
  printf 'v1.2.3\n' > "$repo/VERSION"

  run bash -lc "RELEASE_ROOT='$repo'; source '$BATS_TEST_DIRNAME/../../scripts/release.sh'; read_version"

  [ "$status" -eq 0 ]
  [ "$output" = "v1.2.3" ]
}

@test "release: changelog notes extraction returns only target version section" {
  local repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo"
  cat > "$repo/CHANGELOG.md" <<'EOF'
# Changelog

## v1.2.3 - 2026-03-20
- Added universal release assets.
- Added release script.

## v1.2.2 - 2026-03-19
- Older entry.
EOF

  run bash -lc "RELEASE_ROOT='$repo'; source '$BATS_TEST_DIRNAME/../../scripts/release.sh'; extract_notes_from_changelog 'v1.2.3'"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Added universal release assets."* ]]
  [[ "$output" != *"Older entry."* ]]
}

@test "release: ensure_release_branch rejects non-main branch by default" {
  run bash -lc "source '$BATS_TEST_DIRNAME/../../scripts/release.sh'; ensure_release_branch 'feature/test'"

  [ "$status" -eq 1 ]
  [[ "$output" == *"main"* ]]
}

@test "release: top changelog release section must match VERSION" {
  local repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo"
  cat > "$repo/CHANGELOG.md" <<'EOF'
# Changelog

## v1.2.2 - 2026-03-19
- Older release first.

## v1.2.3 - 2026-03-20
- Target release below top.
EOF

  run bash -lc "RELEASE_ROOT='$repo'; source '$BATS_TEST_DIRNAME/../../scripts/release.sh'; ensure_changelog_current_version_first 'v1.2.3'"

  [ "$status" -eq 1 ]
  [[ "$output" == *"top"* ]] || [[ "$output" == *"first"* ]]
}

@test "release: ensure_gh_authenticated checks gh auth status" {
  local stub_bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$stub_bin"
  cat > "$stub_bin/gh" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
  chmod +x "$stub_bin/gh"

  run bash -lc "PATH='$stub_bin:$PATH'; source '$BATS_TEST_DIRNAME/../../scripts/release.sh'; ensure_gh_authenticated"

  [ "$status" -eq 1 ]
  [[ "$output" == *"gh auth status"* ]]
}

@test "release: ensure_tag_absent allows missing remote tag" {
  local stub_bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$stub_bin"
  cat > "$stub_bin/git" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  rev-parse)
    exit 1
    ;;
  ls-remote)
    exit 2
    ;;
  *)
    echo "unexpected git args: $*" >&2
    exit 99
    ;;
esac
EOF
  chmod +x "$stub_bin/git"

  run bash -lc "PATH='$stub_bin:$PATH'; source '$BATS_TEST_DIRNAME/../../scripts/release.sh'; ensure_tag_absent 'v1.2.3'"

  [ "$status" -eq 0 ]
}

@test "release: ensure_release_absent allows missing GitHub release" {
  local stub_bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$stub_bin"
  cat > "$stub_bin/gh" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "release" && "$2" == "view" ]]; then
  exit 1
fi

echo "unexpected gh args: $*" >&2
exit 99
EOF
  chmod +x "$stub_bin/gh"

  run bash -lc "PATH='$stub_bin:$PATH'; source '$BATS_TEST_DIRNAME/../../scripts/release.sh'; ensure_release_absent 'v1.2.3'"

  [ "$status" -eq 0 ]
}

@test "release: main exits cleanly after successful release flow" {
  local repo="$BATS_TEST_TMPDIR/repo"
  local stub_bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$repo" "$stub_bin"
  cat > "$repo/VERSION" <<'EOF'
v1.2.3
EOF
  cat > "$repo/CHANGELOG.md" <<'EOF'
# Changelog

## v1.2.3 - 2026-03-20
- Test release notes.
EOF
  cat > "$stub_bin/git" <<'EOF'
#!/usr/bin/env bash
case "$1 $2 $3" in
  "branch --show-current ")
    echo main
    exit 0
    ;;
  "diff --quiet ")
    exit 0
    ;;
  "diff --cached --quiet")
    exit 0
    ;;
  "ls-files --others --exclude-standard")
    exit 0
    ;;
  "rev-parse -q --verify")
    exit 1
    ;;
  "ls-remote --exit-code --tags")
    exit 2
    ;;
  "tag -a v1.2.3")
    exit 0
    ;;
  "push origin main")
    exit 0
    ;;
  "push origin v1.2.3")
    exit 0
    ;;
esac

echo "unexpected git args: $*" >&2
exit 99
EOF
  cat > "$stub_bin/gh" <<'EOF'
#!/usr/bin/env bash
case "$1 $2 $3" in
  "auth status ")
    exit 0
    ;;
  "release view v1.2.3")
    exit 1
    ;;
  "release create v1.2.3")
    exit 0
    ;;
esac

echo "unexpected gh args: $*" >&2
exit 99
EOF
  cat > "$stub_bin/swift" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  cat > "$stub_bin/bats" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  cat > "$stub_bin/bun" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$stub_bin/git" "$stub_bin/gh" "$stub_bin/swift" "$stub_bin/bats" "$stub_bin/bun"

  run bash -lc "PATH='$stub_bin:$PATH'; RELEASE_ROOT='$repo' '$BATS_TEST_DIRNAME/../../scripts/release.sh'"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Release v1.2.3 created."* ]]
}
