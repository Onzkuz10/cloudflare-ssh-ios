# Project Plan

## Goal

Build an iOS SSH client that natively supports Cloudflare Tunnels — no jump host, no `cloudflared` binary required on the device. Users point it at a hostname behind a Cloudflare Tunnel, authenticate via Cloudflare Access (SSO), and get a working terminal.

---

## Phases

### Phase 1 — Go tunnel library
**Goal:** Produce a working iOS framework that can open a WebSocket tunnel to a Cloudflare-protected host.

**Tasks:**
- [ ] Read and understand `cloudflared/access/carrier.go` and surrounding SSH proxy code
- [ ] Extract the minimal set of packages needed — tunnel WebSocket logic, CF Access token fetching
- [ ] Strip anything that can't compile for iOS (no `os/exec`, no privileged networking)
- [ ] Define a clean `gomobile`-compatible API surface in `bridge.go`:
  ```go
  func Dial(hostname string, token string) (net.Conn, error)
  ```
- [ ] Compile with `gomobile bind -target ios` and verify `.xcframework` output
- [ ] Write a small Go test harness (macOS CLI) to verify tunnel connects end-to-end

**Risks:**
- `cloudflared` may pull in dependencies that don't compile for iOS — needs audit
- WebSocket library choice matters; `nhooyr.io/websocket` is more mobile-friendly than `gorilla/websocket`

---

### Phase 2 — CF Access OAuth flow
**Goal:** Get a valid `CF_Authorization` JWT from Cloudflare Access in-app.

**Tasks:**
- [ ] Implement PKCE OAuth 2.0 flow using `ASWebAuthenticationSession` (Swift) or a WebView
- [ ] Handle the redirect back to the app with the JWT
- [ ] Store token securely in iOS Keychain (short-lived, ~8hr expiry)
- [ ] Refresh / re-auth flow when token expires mid-session
- [ ] Expose to React Native via a native module

**Notes:**
- Cloudflare Access auth domain is `<team>.cloudflareaccess.com`
- The flow is standard PKCE — well documented in CF docs

---

### Phase 3 — SSH over the tunnel
**Goal:** Establish a real SSH session using the Go tunnel connection as the transport.

**Tasks:**
- [ ] Evaluate SSH library options:
  - `libssh2` (C, battle-tested, used by many iOS SSH apps) — needs `net.Conn` fed in via a custom socket
  - `golang.org/x/crypto/ssh` (pure Go) — can accept any `net.Conn` directly, simpler integration
- [ ] Prefer `golang.org/x/crypto/ssh` — keeps everything in Go, avoids C interop:
  ```go
  conn, _ := cfaccess.Dial(hostname, token)
  sshConn, _, _, _ := ssh.NewClientConn(conn, hostname, config)
  ```
- [ ] Support auth methods: password, SSH key (Ed25519/RSA), SSH certificate (CF short-lived certs)
- [ ] Expose SSH session read/write streams to React Native

---

### Phase 4 — Terminal UI
**Goal:** A usable terminal emulator in React Native.

**Tasks:**
- [ ] Evaluate terminal options:
  - `xterm.js` in a `WKWebView` — proven, full VT100/xterm support
  - `react-native-xterm` — wrapper around the above
  - Custom — not worth it
- [ ] Wire up stdin/stdout between SSH session streams and the terminal
- [ ] Handle window resize (`SIGWINCH` equivalent — SSH channel resize request)
- [ ] Keyboard handling on iOS (software keyboard + external keyboard)
- [ ] Basic gestures: pinch to zoom font size, scroll history

---

### Phase 5 — Host management & UX
**Goal:** A usable app, not just a proof of concept.

**Tasks:**
- [ ] Host list screen — add/edit/delete saved hosts
- [ ] Per-host config: hostname, port (default 22), username, auth method, CF Access team domain
- [ ] Credential storage in iOS Keychain
- [ ] Connection status / error states
- [ ] Reconnect handling (app backgrounded, network switch)
- [ ] Basic settings: font size, theme (dark/light), keep-alive interval

---

### Phase 6 — Polish & distribution
- [ ] TestFlight beta
- [ ] App Store review (tunnelling apps need clear description — see Tailscale, WireGuard precedents)
- [ ] Consider open source release

---

## Key technical decisions

| Decision | Choice | Rationale |
|---|---|---|
| App framework | React Native | Cross-platform option later, good native module story |
| Tunnel implementation | Go via gomobile | Reuse cloudflared source directly |
| SSH library | `golang.org/x/crypto/ssh` | Pure Go, accepts `net.Conn`, no C interop needed |
| Terminal | xterm.js in WKWebView | Most complete VT emulation, battle-tested |
| Auth storage | iOS Keychain | Only secure option for credentials on iOS |
| CF Access flow | ASWebAuthenticationSession | Native iOS, handles redirects properly |

---

## What we're explicitly NOT doing

- **Android** (for now) — gomobile supports it but doubles scope
- **Non-CF-Tunnel SSH** — there are already good apps for that (Prompt, Termius)
- **SFTP / file transfer** — out of scope for v1
- **Mosh** — interesting but separate project

---

## Open questions

- Does Apple allow Network Extension entitlement for this use case, or is a plain WebSocket enough? (Likely plain WebSocket is fine — we're not creating a VPN interface)
- Can `gomobile` handle the full `cloudflared` dependency tree or do we need to manually vendor a trimmed version?
- Short-lived SSH cert support — worth implementing in v1 or defer?
