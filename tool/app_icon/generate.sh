#!/usr/bin/env bash
# Regenerates every platform's app icon from tool/app_icon/render_icon.swift.
# Needs macOS (Swift + AppKit), ImageMagick (`magick`) and Flutter.
set -euo pipefail
cd "$(dirname "$0")/../.."

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
swiftc -O tool/app_icon/render_icon.swift -o "$tmp/render"
r() { "$tmp/render" "$@"; }

# Sources for flutter_launcher_icons (iOS, Android).
r square 1024 assets/icon/icon.png
r foreground 1024 assets/icon/icon_foreground.png

# macOS: drawn per size so small sizes stay crisp.
mac=macos/Runner/Assets.xcassets/AppIcon.appiconset
for s in 16 32 64 128 256 512 1024; do r macos "$s" "$mac/app_icon_$s.png"; done

# Windows.
for s in 16 24 32 48 64 128 256; do r rounded "$s" "$tmp/win_$s.png"; done
magick "$tmp"/win_{16,24,32,48,64,128,256}.png windows/runner/resources/app_icon.ico

# Web.
r rounded 32 web/favicon.png
r square 192 web/icons/Icon-192.png
r square 512 web/icons/Icon-512.png
r maskable 192 web/icons/Icon-maskable-192.png
r maskable 512 web/icons/Icon-maskable-512.png

dart run flutter_launcher_icons
