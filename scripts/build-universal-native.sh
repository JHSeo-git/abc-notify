#!/usr/bin/env bash

set -euo pipefail

ARM64_PATH=""
X86_64_PATH=""
OUTPUT_PATH=""

usage() {
  echo "Usage: $0 --arm64 <path> --x86_64 <path> --output <path>" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --arm64)
      [[ $# -ge 2 ]] || usage
      ARM64_PATH="$2"
      shift 2
      ;;
    --x86_64)
      [[ $# -ge 2 ]] || usage
      X86_64_PATH="$2"
      shift 2
      ;;
    --output)
      [[ $# -ge 2 ]] || usage
      OUTPUT_PATH="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

[[ -n "$ARM64_PATH" && -n "$X86_64_PATH" && -n "$OUTPUT_PATH" ]] || usage

for input in "$ARM64_PATH" "$X86_64_PATH"; do
  if [[ ! -f "$input" ]]; then
    echo "Error: missing input $input" >&2
    exit 1
  fi
done

mkdir -p "$(dirname "$OUTPUT_PATH")"
lipo -create "$ARM64_PATH" "$X86_64_PATH" -output "$OUTPUT_PATH"

if [[ ! -f "$OUTPUT_PATH" ]]; then
  echo "Error: failed to create universal binary at $OUTPUT_PATH" >&2
  exit 1
fi
