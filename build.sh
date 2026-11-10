#!/bin/bash
# Build + install + launch iPhoneLatest.app → /Applications/iPhoneLatest.app
#
#   ./build.sh                 build, sign, install, (re)launch
#   SIGN_ID="…" ./build.sh     sign with a specific identity
#
# Signing: uses $SIGN_ID, else the first "Apple Development" identity in your keychain,
# else ad-hoc. A stable identity keeps permissions + Open at Login across rebuilds.
set -euo pipefail
cd "$(dirname "$0")"
VERSION="1.0"
APP=iPhoneLatest.app; DEST="/Applications/$APP"
SIGN_ID="${SIGN_ID:-$(security find-identity -v -p codesigning 2>/dev/null | grep -F "Apple Development" | head -1 | sed 's/.*"\(.*\)"/\1/')}"

echo "==> Compiling"
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
xcrun swiftc -O App/main.swift App/SupportHelp.swift -o "$APP/Contents/MacOS/iPhoneLatest" \
    -framework Cocoa -framework SwiftUI -framework ServiceManagement

echo "==> Bundling"
if [[ ! -f App/AppIcon.icns ]]; then
  xcrun swift App/make-icon.swift /tmp/iphonelatest.iconset && iconutil -c icns /tmp/iphonelatest.iconset -o App/AppIcon.icns
fi
/bin/cp App/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cat > "$APP/Contents/Info.plist" <<P
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>org.esaruoho.iphonelatest</string>
  <key>CFBundleName</key><string>iPhoneLatest</string>
  <key>CFBundleDisplayName</key><string>iPhoneLatest</string>
  <key>CFBundleExecutable</key><string>iPhoneLatest</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$(git rev-list --count HEAD 2>/dev/null || echo 1)</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
  <key>LSUIElement</key><true/>
  <key>CFBundleURLTypes</key><array><dict>
    <key>CFBundleURLName</key><string>org.esaruoho.iphonelatest</string>
    <key>CFBundleURLSchemes</key><array><string>iphonelatest</string></array>
  </dict></array>
  <key>NSHumanReadableCopyright</key><string>Esa Ruoho — github.com/esaruoho/apple-continuity-camera-photographer</string>
</dict></plist>
P

echo "==> Signing (${SIGN_ID:-ad-hoc})"
if [[ -n "$SIGN_ID" ]]; then codesign -s "$SIGN_ID" --force "$APP" >/dev/null; else codesign -s - --force "$APP"; fi

echo "==> Installing to $DEST"
pkill -x iPhoneLatest || true
rm -rf "$DEST"; /bin/cp -R "$APP" "$DEST"; rm -rf "$APP"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DEST"
open "$DEST"; echo "📱 iPhoneLatest $VERSION running: $DEST"
