#!/bin/bash
# setup-mac.sh — one-shot dev setup for cloudflare-ssh-ios on macOS
# Run from the repo root: ./scripts/setup-mac.sh
set -euo pipefail

MOBILE_VERSION="v0.0.0-20240213143359-d1f7d3436075"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
XCFRAMEWORK_OUT="$REPO_ROOT/app/ios/CFTunnelPod/CFTunnel.xcframework"

# ── colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }
die()  { echo -e "${RED}✗ $*${NC}" >&2; exit 1; }
step() { echo -e "\n${YELLOW}▶ $*${NC}"; }

# ── preflight checks ──────────────────────────────────────────────────────────
step "Checking prerequisites"

command -v go    >/dev/null || die "Go not found. Install from https://go.dev/dl/"
command -v node  >/dev/null || die "Node not found. Install from https://nodejs.org/"
command -v xcodebuild >/dev/null || die "Xcode not found. Install from the App Store."
command -v pod   >/dev/null || warn "CocoaPods not found — will try 'bundle exec pod' instead"

GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
NODE_VERSION=$(node --version | sed 's/v//')
ok "Go $GO_VERSION"
ok "Node $NODE_VERSION"
ok "Xcode $(xcodebuild -version 2>/dev/null | head -1 | awk '{print $2}')"

# ── gomobile ──────────────────────────────────────────────────────────────────
step "Installing gomobile + gobind @ $MOBILE_VERSION"
cd "$REPO_ROOT/go"
go install golang.org/x/mobile/cmd/gomobile@$MOBILE_VERSION
go install golang.org/x/mobile/cmd/gobind@$MOBILE_VERSION
ok "gomobile $(gomobile version 2>/dev/null || echo 'installed')"

# ── build xcframework ─────────────────────────────────────────────────────────
step "Building CFTunnel.xcframework"
rm -rf "$XCFRAMEWORK_OUT"
gomobile bind \
  -target ios \
  -o "$XCFRAMEWORK_OUT" \
  ./cftunnel/
ok "Built → $XCFRAMEWORK_OUT"

# ── js deps ───────────────────────────────────────────────────────────────────
step "Installing JS dependencies"
cd "$REPO_ROOT/app"
npm install
ok "node_modules ready"

# ── cocoapods ─────────────────────────────────────────────────────────────────
step "Installing CocoaPods"
cd "$REPO_ROOT/app/ios"
if command -v bundle >/dev/null && [ -f "$REPO_ROOT/app/Gemfile" ]; then
  bundle install --quiet
  bundle exec pod install
else
  pod install
fi
ok "Pods installed"

# ── done ──────────────────────────────────────────────────────────────────────
echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Next steps:"
echo "  1. Plug in your iPhone via USB"
echo "  2. open $REPO_ROOT/app/ios/CloudflareSSH.xcworkspace"
echo "  3. Select your device in the toolbar"
echo "  4. Hit ▶ Run (or ⌘R)"
echo ""
echo "  To rebuild the Go framework after changes:"
echo "  cd go && gomobile bind -target ios -o ../app/ios/CFTunnelPod/CFTunnel.xcframework ./cftunnel/"
echo ""
