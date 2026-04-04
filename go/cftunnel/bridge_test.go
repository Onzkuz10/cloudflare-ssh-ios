package cftunnel

import (
	"strings"
	"testing"
)

func TestPing(t *testing.T) {
	result := Ping("ssh.example.com")
	if !strings.Contains(result, "ssh.example.com") {
		t.Errorf("expected hostname in result, got: %s", result)
	}
}
