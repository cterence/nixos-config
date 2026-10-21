package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"time"
)

const hydraBase = "https://hydra.nixos.org"

// Build statuses as returned by Hydra's buildstatus field.
const (
	statusSuccess = 0
)

// Build is the subset of Hydra's build JSON the sweep needs.
type Build struct {
	ID          int    `json:"id"`
	BuildStatus int    `json:"buildstatus"`
	Finished    int    `json:"finished"`
	NixName     string `json:"nixname"`
	Job         string `json:"job"`
	DrvPath     string `json:"drvpath"`
}

// URL is the human-facing build page.
func (b Build) URL() string { return fmt.Sprintf("%s/build/%d", hydraBase, b.ID) }

// Status classifies a build: success, failed, or pending (still running).
func (b Build) Status() string {
	switch {
	case b.Finished == 1 && b.BuildStatus == statusSuccess:
		return "success"
	case b.Finished == 0:
		return "pending"
	default:
		return "failed"
	}
}

// Hydra queries hydra.nixos.org's REST API.
type Hydra struct {
	Base string
	HTTP *http.Client
}

func NewHydra() *Hydra {
	return &Hydra{Base: hydraBase, HTTP: &http.Client{Timeout: 30 * time.Second}}
}

func (h *Hydra) get(path string) ([]byte, error) {
	req, err := http.NewRequest(http.MethodGet, h.Base+path, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/json")
	resp, err := h.HTTP.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(io.LimitReader(resp.Body, 1<<22))
	if err != nil {
		return nil, err
	}
	if resp.StatusCode == http.StatusNotFound {
		return nil, nil // job unknown to Hydra: not an error, just no signal
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("hydra %s: HTTP %d", path, resp.StatusCode)
	}
	return body, nil
}

// LatestBuild returns the job's most recent build, or nil if Hydra has no
// such job.
func (h *Hydra) LatestBuild(job string) (*Build, error) {
	body, err := h.get("/job/nixpkgs/unstable/" + job + "/latest")
	if err != nil || body == nil {
		return nil, err
	}
	var b Build
	if err := json.Unmarshal(body, &b); err != nil {
		return nil, fmt.Errorf("parsing build for %s: %w", job, err)
	}
	return &b, nil
}

var buildIDRe = regexp.MustCompile(`/build/(\d+)`)

// RecentBuildIDs lists the job's build IDs, newest first, from the job
// history's first page.
func (h *Hydra) RecentBuildIDs(job string) ([]int, error) {
	body, err := h.get("/job/nixpkgs/unstable/" + job + "/all?page=1")
	if err != nil || body == nil {
		return nil, err
	}
	matches := buildIDRe.FindAllSubmatch(body, -1)
	ids := make([]int, 0, len(matches))
	seen := map[int]bool{}
	for _, m := range matches {
		id, _ := strconv.Atoi(string(m[1]))
		if !seen[id] {
			seen[id] = true
			ids = append(ids, id)
		}
	}
	return ids, nil
}

// LastGood walks the job's history and returns the newest successful
// build's version. Bounded: gives up after maxTries builds.
func (h *Hydra) LastGood(job string, maxTries int) (string, *Build, error) {
	ids, err := h.RecentBuildIDs(job)
	if err != nil || ids == nil {
		return "", nil, err
	}
	if len(ids) > maxTries {
		ids = ids[:maxTries]
	}
	for _, id := range ids {
		body, err := h.get(fmt.Sprintf("/build/%d", id))
		if err != nil || body == nil {
			continue
		}
		var b Build
		if err := json.Unmarshal(body, &b); err != nil {
			continue
		}
		if b.Status() == "success" {
			return stripVersion(b.NixName, job), &b, nil
		}
	}
	return "", nil, nil
}

// stripVersion extracts the version from a nixname like "picard-3.0.2",
// given the job name "picard.<system>".
func stripVersion(nixName, job string) string {
	pkg, _, _ := strings.Cut(job, ".")
	if v, ok := strings.CutPrefix(nixName, pkg+"-"); ok {
		return v
	}
	return nixName
}

// indexVersionSep finds the first "-<digit>" separator in an attr name,
// e.g. "picard-3.0.2" -> 6. Returns -1 when the name has no version part.
func indexVersionSep(name string) int {
	for i := 1; i+1 < len(name); i++ {
		if name[i] == '-' && name[i+1] >= '0' && name[i+1] <= '9' {
			return i
		}
	}
	return -1
}
