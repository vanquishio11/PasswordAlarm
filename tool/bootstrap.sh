#!/usr/bin/env bash
set -euo pipefail

# Creates missing Flutter platform folders and patches iOS to not require code signing.
# Run from repo root: bash tool/bootstrap.sh

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter is not installed or not on PATH."
  echo "Install Flutter, then rerun this script."
  exit 1
fi

NEED_CREATE=0
for d in android ios web macos windows linux; do
  if [ ! -d "$d" ]; then
    NEED_CREATE=1
  fi
done

if [ "$NEED_CREATE" -eq 1 ]; then
  echo "Generating Flutter platform folders (flutter create .)..."
  tmpdir="$(mktemp -d)"
  cp -R lib pubspec.yaml analysis_options.yaml README.md "$tmpdir"/
  flutter create . >/dev/null
  rm -rf lib pubspec.yaml analysis_options.yaml README.md
  cp -R "$tmpdir"/lib .
  cp "$tmpdir"/pubspec.yaml "$tmpdir"/analysis_options.yaml "$tmpdir"/README.md .
  rm -rf "$tmpdir"
else
  echo "Platform folders already exist; skipping flutter create."
fi

bash tool/patch_ios_no_signing.sh
echo "Done."
