#!/usr/bin/env bash
set -euo pipefail

##
# Build an "unsigned IPA-shaped" artifact for a Flutter app.
#
# Notes:
# - This is NOT a distributable IPA for iOS devices.
# - It is a convenience artifact for static inspection / unpacking / diffing.
# - The output will NOT contain a valid signature or embedded.mobileprovision.
#
# Usage (from repo root):
#   bash tools/build_unsigned_ipa.sh apps/gauge_grid
#
# Optional:
#   OUT_IPA=/abs/path/to/unsign.ipa bash tools/build_unsigned_ipa.sh apps/gauge_grid
##

if [[ $# -ne 1 ]]; then
  echo "Usage: bash tools/build_unsigned_ipa.sh <app_dir>" >&2
  exit 64
fi

APP_DIR="$1"

if [[ ! -d "$APP_DIR" ]]; then
  echo "App dir not found: $APP_DIR" >&2
  exit 66
fi

if [[ ! -f "$APP_DIR/pubspec.yaml" ]]; then
  echo "Not a Flutter app dir (missing pubspec.yaml): $APP_DIR" >&2
  exit 66
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_ABS="$REPO_ROOT/$APP_DIR"
APP_NAME="$(basename "$APP_DIR")"

DEFAULT_OUT="$REPO_ROOT/$APP_DIR/build/ios/ipa/${APP_NAME}_unsign.ipa"
OUT_IPA="${OUT_IPA:-$DEFAULT_OUT}"

echo "Building iOS app (no codesign): $APP_DIR"
(cd "$APP_ABS" && flutter pub get >/dev/null)
(cd "$APP_ABS" && flutter build ios --no-codesign >/dev/null)

APP_BUNDLE_DIR="$APP_ABS/build/ios/iphoneos/Runner.app"
if [[ ! -d "$APP_BUNDLE_DIR" ]]; then
  echo "Runner.app not found at: $APP_BUNDLE_DIR" >&2
  echo "Hint: ensure Xcode toolchain is installed and build succeeded." >&2
  exit 70
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TMP_DIR/Payload"
cp -R "$APP_BUNDLE_DIR" "$TMP_DIR/Payload/Runner.app"

mkdir -p "$(dirname "$OUT_IPA")"
(cd "$TMP_DIR" && /usr/bin/zip -qry "$OUT_IPA" Payload)

echo "Done:"
echo "  $OUT_IPA"
