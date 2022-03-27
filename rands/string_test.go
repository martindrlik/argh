package rands_test

import (
	"strings"
	"testing"

	"github.com/martindrlik/argh/rands"
)

func TestPassword(t *testing.T) {
	fs := strings.Split(rands.Password(), "-")
	if len(fs) != 4 {
		t.Errorf("expected 4 parts got %v", len(fs))
	}
	for i, f := range fs {
		if len(f) != 4 {
			t.Errorf("expected %vth part to have 4 characters got %v", i+1, len(f))
		}
	}
}
