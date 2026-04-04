# cloudflare-ssh-ios

An iOS SSH client with native [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) support, built with React Native.

Connects to servers behind Cloudflare Tunnels by reimplementing the `cloudflared access ssh` proxy using the original Go source compiled to an iOS framework via `gomobile`.

---

## How it works

```
iPhone App
  └── CF Access OAuth (WebView / ASWebAuthenticationSession)
        └── JWT token → WebSocket to Cloudflare edge
              └── Raw TCP tunnel → your server :22
                    └── SSH session (libssh2)
```

1. **Auth** — PKCE OAuth flow against Cloudflare Access, stores short-lived JWT
2. **Tunnel** — Go code from `cloudflared` compiled via `gomobile`, opens WebSocket tunnel to CF edge
3. **SSH** — `libssh2` native module accepts the tunnel as its transport layer
4. **UI** — React Native terminal emulator ([xterm.js](https://xtermjs.org/) in a WebView or `react-native-xterm`)

---

## Project structure

```
cloudflare-ssh-ios/
├── go/                        # Go tunnel library
│   ├── cfaccess/              # Extracted + trimmed cloudflared access logic
│   │   ├── tunnel.go          # WebSocket tunnel to CF edge
│   │   ├── auth.go            # CF Access JWT handling
│   │   └── bridge.go          # gomobile-compatible API surface
│   └── go.mod
├── ios/                       # Native iOS / Xcode project
│   ├── CFTunnel.xcframework   # Output of gomobile bind
│   └── SSHBridge/             # libssh2 Swift wrapper + RN native module
├── src/                       # React Native app
│   ├── screens/
│   │   ├── HostList.tsx       # Saved hosts
│   │   ├── Connect.tsx        # Auth + connection flow
│   │   └── Terminal.tsx       # SSH terminal UI
│   ├── modules/
│   │   ├── CFTunnel.ts        # RN bridge to Go framework
│   │   └── SSH.ts             # RN bridge to libssh2
│   └── storage/               # Host configs (keychain for credentials)
├── PLAN.md
└── README.md
```

---

## Development setup

### Prerequisites

- Go 1.22+
- `gomobile` (`go install golang.org/x/mobile/cmd/gomobile@latest`)
- Xcode 15+
- React Native 0.74+
- Node 20+

### Build the Go framework

```bash
cd go
gomobile init
gomobile bind -target ios -o ../ios/CFTunnel.xcframework .
```

### Run the app

```bash
npm install
npx react-native run-ios
```

---

## References

- [cloudflare/cloudflared](https://github.com/cloudflare/cloudflared) — source of the tunnel/access logic
- [golang.org/x/mobile](https://github.com/golang/mobile) — gomobile for iOS framework compilation
- [Tailscale iOS app](https://github.com/tailscale/tailscale) — reference for Go + iOS Network Extension pattern
- [libssh2](https://libssh2.org/) — SSH client C library

---

## Status

🚧 Early planning phase — see [PLAN.md](./PLAN.md)
