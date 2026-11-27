#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Usage: $0 <version> <bundle_dir> <output_deb>}"
BUNDLE_DIR="${2:?Usage: $0 <version> <bundle_dir> <output_deb>}"
OUTPUT_DEB="${3:?Usage: $0 <version> <bundle_dir> <output_deb>}"

# Strip leading v if passed a git tag like v0.3.0
VERSION="${VERSION#v}"

STAGE_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGE_DIR"' EXIT

install -d \
  "$STAGE_DIR/DEBIAN" \
  "$STAGE_DIR/opt/bassdrive-radio" \
  "$STAGE_DIR/usr/bin" \
  "$STAGE_DIR/usr/share/applications" \
  "$STAGE_DIR/usr/share/metainfo" \
  "$STAGE_DIR/usr/share/icons/hicolor/512x512/apps"

cp -a "$BUNDLE_DIR"/. "$STAGE_DIR/opt/bassdrive-radio/"
ln -s /opt/bassdrive-radio/bassdrive_radio "$STAGE_DIR/usr/bin/bassdrive_radio"

install -m 644 packaging/linux/io.maido.bassdrive.desktop \
  "$STAGE_DIR/usr/share/applications/io.maido.bassdrive.desktop"
install -m 644 packaging/linux/io.maido.bassdrive.metainfo.xml \
  "$STAGE_DIR/usr/share/metainfo/io.maido.bassdrive.metainfo.xml"
install -m 644 assets/icon/icon.png \
  "$STAGE_DIR/usr/share/icons/hicolor/512x512/apps/io.maido.bassdrive.png"

INSTALLED_SIZE="$(du -sk "$STAGE_DIR/opt" | awk '{print $1}')"

cat > "$STAGE_DIR/DEBIAN/control" <<EOF
Package: bassdrive-radio
Version: ${VERSION}
Section: sound
Priority: optional
Architecture: amd64
Installed-Size: ${INSTALLED_SIZE}
Depends: libgtk-3-0, libmpv2 | libmpv1
Maintainer: Maido <https://github.com/v3rm0n/bassdrive-app>
Homepage: https://github.com/v3rm0n/bassdrive-app
Description: Bassdrive 24/7 Drum & Bass Internet Radio Player
 Stream Bassdrive 24/7 Drum & Bass radio and browse archived shows
 with favourites, progress tracking, and offline caching.
EOF

dpkg-deb --build --root-owner-group "$STAGE_DIR" "$OUTPUT_DEB"
