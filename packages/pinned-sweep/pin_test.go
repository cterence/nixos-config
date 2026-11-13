package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestPinSkipsBadVerdict(t *testing.T) {
	dir := t.TempDir()
	empty := filepath.Join(dir, "empty.json")
	if err := os.WriteFile(empty, nil, 0o644); err != nil {
		t.Fatal(err)
	}
	corrupt := filepath.Join(dir, "corrupt.json")
	if err := os.WriteFile(corrupt, []byte(`{"pins": [`), 0o644); err != nil {
		t.Fatal(err)
	}

	for name, file := range map[string]string{"empty": empty, "corrupt": corrupt} {
		t.Run(name, func(t *testing.T) {
			// Must neither crash (exit 1) nor evaluate the flake.
			if code := cmdPin([]string{"--from-verdict", file, "--preview"}); code != 0 {
				t.Fatalf("cmdPin on %s verdict = %d, want 0", name, code)
			}
		})
	}
}
