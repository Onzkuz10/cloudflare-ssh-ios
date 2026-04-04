# cloudflare-ssh-ios

An iOS SSH client with native [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) support, built with React Native.

Connects to servers behind Cloudflare Tunnels by reimplementing the `cloudflared access ssh` proxy using the original Go source compiled to an iOS framework via `gomobile`.

![CI](https://github.com/Ankcorn/cloudflare-ssh-ios/actions/workflows/build.yml/badge.svg)

---

## How it works

```
iPhone App
  └── CF Access OAuth (ASWebAuthenticationSession)
        └── JWT token → WebSocket to Cloudflare edge
              └── Raw TCP tunnel → your server :22
                    └── SSH session (golang.org/x/crypto/ssh)
```

---

## Project structure

```
cloudflare-ssh-ios/
├── go/                        # Go tunnel library
│   └── cftunnel/
│       ├── bridge.go          # gomobile-compatible API (Ping → real Dial in Phase 2)
│       └── bridge_test.go
├── app/                       # React Native app
│   ├── src/modules/CFTunnel.ts  # JS bridge to native module
│   ├── App.tsx                  # Phase 1 smoke-test UI
│   └── ios/
│       ├── CFTunnelBridge/    # ObjC RCT native module
│       └── CFTunnel.xcframework  # gomobile output (gitignored, built by CI/setup script)
├── scripts/
│   └── setup-mac.sh           # One-shot Mac setup
└── .github/workflows/build.yml
```

---

## Getting started (Mac)

```bash
git clone https://github.com/Ankcorn/cloudflare-ssh-ios
cd cloudflare-ssh-ios
./scripts/setup-mac.sh
```

Then open `app/ios/CloudflareSSH.xcworkspace` in Xcode, select your iPhone, hit **Run**.

---

## CI

Three jobs run on every push:

| Job | Runner | What it does |
|---|---|---|
| `go-test` | ubuntu-latest | `go test ./...` on the tunnel library |
| `build-ios-framework` | macos-15 | `gomobile bind` → uploads `CFTunnel.xcframework` artifact |
| `js-check` | ubuntu-latest | `tsc --noEmit` on the RN app |

Download the latest `CFTunnel.xcframework` from the Actions artifacts tab if you don't want to build Go locally.

---

## References

- [cloudflare/cloudflared](https://github.com/cloudflare/cloudflared)
- [golang.org/x/mobile](https://github.com/golang/mobile)
- [Tailscale iOS](https://github.com/tailscale/tailscale) — reference for Go + iOS pattern

---

## Status

🚧 Phase 1 — Go bridge smoke test. See [PLAN.md](./PLAN.md)
