// Package cftunnel provides a gomobile-compatible API for connecting to
// Cloudflare Tunnel endpoints. Phase 1: stub that proves the build pipeline works.
package cftunnel

import "fmt"

// Ping returns a message confirming the Go framework is linked correctly.
// Replace with real WebSocket dial logic in Phase 2.
func Ping(hostname string) string {
	return fmt.Sprintf("cftunnel: would dial %s via Cloudflare edge", hostname)
}
