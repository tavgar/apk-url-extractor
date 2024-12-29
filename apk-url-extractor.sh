#!/usr/bin/env bash
#
# apk-url-extractor.sh
#
# A simple Bash script to:
# 1) Decompile an APK using apktool.
# 2) Recursively search for URLs in the decompiled codebase.
# 3) Optionally filter by a specific domain (e.g., "example.com").
#
# Requirements:
# - apktool
# - grep (with extended regex)
#
# Usage:
#   ./apk-url-extractor.sh -a /path/to/myapp.apk [-d mydomain.com]
#
# Examples:
#   # Extract all URLs (any domain) from "myapp.apk"
#   ./apk-url-extractor.sh -a myapp.apk
#
#   # Extract only URLs containing "tiktok.com"
#   ./apk-url-extractor.sh -a myapp.apk -d tiktok.com
#

set -euo pipefail

# Default values
APK_PATH=""
DOMAIN=""
TMP_OUT_DIR="apk_decompiled_$(date +%s)"

show_help() {
  echo "Usage: $0 -a <apk_file> [-d <domain>]"
  echo
  echo "  -a <apk_file>  : Path to the APK file."
  echo "  -d <domain>    : (Optional) Domain to filter on (e.g. 'example.com')."
  echo
  echo "Example:"
  echo "  $0 -a myapp.apk                     # Decompile and extract ALL URLs"
  echo "  $0 -a myapp.apk -d tiktok.com       # Only show URLs containing 'tiktok.com'"
  echo
  exit 1
}

# Parse arguments
while getopts "a:d:h" opt; do
  case ${opt} in
    a )
      APK_PATH="$OPTARG"
      ;;
    d )
      DOMAIN="$OPTARG"
      ;;
    h )
      show_help
      ;;
    \? )
      show_help
      ;;
  esac
done

if [[ -z "$APK_PATH" ]]; then
  echo "[!] Error: APK path not specified."
  show_help
fi

if [[ ! -f "$APK_PATH" ]]; then
  echo "[!] Error: APK file '$APK_PATH' not found."
  exit 1
fi

# 1) Decompile the APK with apktool
echo "[+] Decompiling '$APK_PATH' into '$TMP_OUT_DIR'..."
apktool d "$APK_PATH" -o "$TMP_OUT_DIR" --force

# 2) Construct the grep regex for URLs
#    This pattern matches http:// or https://, then any non-delimiter chars, then domain?
#    We'll do two things:
#      a) If DOMAIN is specified, we'll only match that domain
#      b) If DOMAIN is empty, match any domain

if [[ -n "$DOMAIN" ]]; then
  echo "[+] Searching for URLs containing '$DOMAIN'..."
  REGEX="https?://[^\"'()<>]*${DOMAIN}[^\"'()<>]*"
else
  echo "[+] Searching for ALL URLs..."
  REGEX="https?://[^\"'()<>]*"
fi

# 3) grep recursively in the decompiled folder
#    -E: extended regex
#    -o: only print the matching part
#    -h: no filename
#    -r: recursive
#    -I: skip binary files
#    -a: treat all files as text
#    sort -u: unique
#    Typically you'd want to limit the grep to .smali, .xml, .json, .js, .txt, etc. 
#    But let's keep it broad for now.

echo
echo "[+] Extracting matching URLs..."
grep -Eaorh "$REGEX" "$TMP_OUT_DIR" 2>/dev/null \
  | sort -u

echo
echo "[+] Done!"
echo "[+] Decompiled folder: $TMP_OUT_DIR"
echo "[+] Tip: Review the output above or redirect script output to a file."
