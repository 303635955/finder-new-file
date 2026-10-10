#!/bin/bash
set -euo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
destination="${1:-$project_dir/dist}"
app="$destination/新建文件.app"
extension="$app/Contents/PlugIns/NewFileExtension.appex"
target="$(uname -m)-apple-macos14.0"

mkdir -p "$app/Contents/MacOS" "$extension/Contents/MacOS"

cat > "$destination/extension.entitlements" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>com.apple.security.app-sandbox</key><true/>
  <key>com.apple.security.files.user-selected.read-write</key><true/>
  <key>com.apple.security.temporary-exception.files.absolute-path.read-write</key>
  <array><string>/Users/</string><string>/Volumes/</string></array>
</dict></plist>
PLIST

cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleDevelopmentRegion</key><string>zh_CN</string>
  <key>CFBundleDisplayName</key><string>新建文件</string>
  <key>CFBundleExecutable</key><string>NewFileApp</string>
  <key>CFBundleIdentifier</key><string>dev.local.findernewfile</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>新建文件</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleSupportedPlatforms</key><array><string>MacOSX</string></array>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST

cat > "$extension/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleDevelopmentRegion</key><string>zh_CN</string>
  <key>CFBundleDisplayName</key><string>新建文件</string>
  <key>CFBundleExecutable</key><string>NewFileExtension</string>
  <key>CFBundleIdentifier</key><string>dev.local.findernewfile.extension</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>新建文件</string>
  <key>CFBundlePackageType</key><string>XPC!</string>
  <key>CFBundleSupportedPlatforms</key><array><string>MacOSX</string></array>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSUIElement</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
  <key>NSExtension</key><dict>
    <key>NSExtensionAttributes</key><dict/>
    <key>NSExtensionPointIdentifier</key><string>com.apple.FinderSync</string>
    <key>NSExtensionPrincipalClass</key><string>FinderSync</string>
  </dict>
</dict></plist>
PLIST

swiftc -target "$target" -parse-as-library -module-name NewFileApp \
  "$project_dir/Sources/App.swift" -framework AppKit \
  -o "$app/Contents/MacOS/NewFileApp"
swiftc -target "$target" -emit-executable \
  -Xlinker -e -Xlinker _NSExtensionMain -module-name NewFileExtension \
  "$project_dir/Sources/NewFileCore.swift" "$project_dir/Sources/FinderSync.swift" \
  -framework AppKit -framework FinderSync \
  -o "$extension/Contents/MacOS/NewFileExtension"

codesign --force --sign - --entitlements "$destination/extension.entitlements" "$extension"
codesign --force --sign - "$app"
codesign --verify --deep --strict --verbose=2 "$app"

echo "$app"
