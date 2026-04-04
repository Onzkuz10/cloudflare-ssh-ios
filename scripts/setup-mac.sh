#!/bin/bash
# Run this on your Mac after cloning to wire up the Go framework.
# Requires: Go, Xcode, CocoaPods

set -e

echo "→ Installing gomobile..."
go install golang.org/x/mobile/cmd/gomobile@latest
go install golang.org/x/mobile/cmd/gobind@latest
(cd go && gomobile init)

echo "→ Building CFTunnel.xcframework..."
(cd go && gomobile bind -target ios -o ../app/ios/CFTunnel.xcframework ./cftunnel/)

echo "→ Installing JS dependencies..."
(cd app && npm install)

echo "→ Installing CocoaPods..."
(cd app/ios && bundle exec pod install)

echo ""
echo "✅ Done! Open app/ios/CloudflareSSH.xcworkspace in Xcode,"
echo "   select your device, and hit Run."
