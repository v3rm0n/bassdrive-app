#!/usr/bin/env bash
set -euo pipefail

BUNDLE_DIR="${1:?Usage: $0 <bundle_dir> <output_appimage>}"
OUTPUT_APPIMAGE="${2:?Usage: $0 <bundle_dir> <output_appimage>}"

APPDIR="$(mktemp -d)/BassdriveRadio.AppDir"
trap 'rm -rf "$(dirname "$APPDIR")"' EXIT

install -d \
  "$APPDIR/usr/bin" \
  "$APPDIR/usr/share/applications" \
  "$APPDIR/usr/share/metainfo" \
  "$APPDIR/usr/share/icons/hicolor/512x512/apps"

cp -a "$BUNDLE_DIR"/. "$APPDIR/usr/bin/"
install -m 644 packaging/linux/io.maido.bassdrive.desktop \
  "$APPDIR/io.maido.bassdrive.desktop"
install -m 644 packaging/linux/io.maido.bassdrive.desktop \
  "$APPDIR/usr/share/applications/io.maido.bassdrive.desktop"
install -m 644 packaging/linux/io.maido.bassdrive.metainfo.xml \
  "$APPDIR/usr/share/metainfo/io.maido.bassdrive.appdata.xml"
install -m 644 assets/icon/icon.png "$APPDIR/io.maido.bassdrive.png"
install -m 644 assets/icon/icon.png \
  "$APPDIR/usr/share/icons/hicolor/512x512/apps/io.maido.bassdrive.png"

cat > "$APPDIR/AppRun" <<'EOF'
#!/usr/bin/env bash
HERE="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="${HERE}/usr/bin/lib:${LD_LIBRARY_PATH:-}"
exec "${HERE}/usr/bin/bassdrive_radio" "$@"
EOF
chmod +x "$APPDIR/AppRun"

APPIMAGETOOL="${APPIMAGETOOL:-appimagetool}"
ARCH=x86_64 "$APPIMAGETOOL" --appimage-extract-and-run "$APPDIR" "$OUTPUT_APPIMAGE"
