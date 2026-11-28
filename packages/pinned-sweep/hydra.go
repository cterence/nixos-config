package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"math/rand/v2"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"
)

const hydraBase = "https://hydra.nixos.org"

// Hydra 429s above a handful of concurrent requests, so total in-flight
// requests are capped process-wide rather than per closure.
const (
	hydraConcurrency = 4
	maxRetryAfter    = 60 * time.Second
)

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
	Timestamp   int64  `json:"timestamp"`
}

// UTCDate is the multiverse selector for the revision pin: the date of
// the build, which multiverse maps to the nixpkgs revision current then.
func (b Build) UTCDate() string {
	if b.Timestamp == 0 {
		return ""
	}
	return time.Unix(b.Timestamp, 0).UTC().Format("2006-01-02")
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

// Hydra queries hydra.nixos.org's REST API. Concurrent-safe; LatestBuild
// results (including 404s) are memoized for the process lifetime.
type Hydra struct {
	Base string
	HTTP *http.Client

	// ctx bounds every request; sem caps total in-flight requests.
	ctx context.Context
	sem chan struct{}

	mu     sync.Mutex
	latest map[string]*Build

	cdMu    sync.Mutex
	cdUntil time.Time
}

func NewHydra() *Hydra {
	return &Hydra{
		Base:   hydraBase,
		HTTP:   &http.Client{Timeout: 30 * time.Second},
		ctx:    context.Background(),
		sem:    make(chan struct{}, hydraConcurrency),
		latest: map[string]*Build{},
	}
}

// once performs a single GET under the process-wide concurrency cap.
func (h *Hydra) once(path string) (*http.Response, []byte, error) {
	h.sem <- struct{}{}
	defer func() { <-h.sem }()
	req, err := http.NewRequestWithContext(h.ctx, http.MethodGet, h.Base+path, nil)
	if err != nil {
		return nil, nil, err
	}
	req.Header.Set("Accept", "application/json")
	req.Header.Set("User-Agent", "pinned-sweep/"+version+" (+https://github.com/cterence/nixos-config)")
	resp, err := h.HTTP.Do(req)
	if err != nil {
		return nil, nil, err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(io.LimitReader(resp.Body, 1<<22))
	if err != nil {
		return nil, nil, err
	}
	return resp, body, nil
}

func (h *Hydra) get(path string) ([]byte, error) {
	const maxAttempts = 6
	for attempt := 1; ; attempt++ {
		if h.waitCooldown() {
			// Stagger workers waking from a shared penalty window.
			time.Sleep(time.Duration(rand.IntN(250)) * time.Millisecond)
		}
		if err := h.ctx.Err(); err != nil {
			return nil, err
		}
		resp, body, err := h.once(path)
		if err != nil {
			return nil, err
		}
		switch {
		case resp.StatusCode == http.StatusNotFound:
			return nil, nil // job unknown to Hydra: not an error, just no signal
		case resp.StatusCode == http.StatusTooManyRequests && attempt < maxAttempts:
			// Only an explicit Retry-After is worth freezing every worker
			// for; otherwise back off this request alone.
			if d, ok := retryAfter(resp); ok {
				h.penalty(d)
			} else {
				time.Sleep(jitteredBackoff(attempt))
			}
		case resp.StatusCode != http.StatusOK:
			return nil, fmt.Errorf("hydra %s: HTTP %d", path, resp.StatusCode)
		default:
			return body, nil
		}
	}
}

// retryAfter is the backoff the server explicitly asked for, if it named one.
func retryAfter(resp *http.Response) (time.Duration, bool) {
	v := resp.Header.Get("Retry-After")
	if v == "" {
		return 0, false
	}
	secs, err := strconv.Atoi(v)
	if err != nil || secs < 0 {
		return 0, false
	}
	return min(time.Duration(secs)*time.Second, maxRetryAfter), true
}

// jitteredBackoff spreads retries of a throttled request over 100ms-3.2s so
// a burst of 429s does not resolve into a second burst.
func jitteredBackoff(attempt int) time.Duration {
	d := 200 * time.Millisecond << uint(min(attempt-1, 4))
	return d/2 + time.Duration(rand.Int64N(int64(d)))
}

// penalty delays every worker until the cooldown expires; 429s are shared so
// the whole process backs off instead of each goroutine hammering on.
func (h *Hydra) penalty(d time.Duration) {
	h.cdMu.Lock()
	if until := time.Now().Add(d); until.After(h.cdUntil) {
		h.cdUntil = until
	}
	h.cdMu.Unlock()
}

// waitCooldown sleeps through any active penalty and reports whether it waited.
func (h *Hydra) waitCooldown() bool {
	waited := false
	for {
		h.cdMu.Lock()
		d := time.Until(h.cdUntil)
		h.cdMu.Unlock()
		if d <= 0 {
			return waited
		}
		time.Sleep(d)
		waited = true
	}
}

// LatestBuild returns the job's most recent build, or nil if Hydra has no
// such job. Results are memoized per process.
func (h *Hydra) LatestBuild(job string) (*Build, error) {
	h.mu.Lock()
	if b, ok := h.latest[job]; ok {
		h.mu.Unlock()
		return b, nil
	}
	h.mu.Unlock()
	body, err := h.get("/job/nixpkgs/unstable/" + job + "/latest")
	if err != nil {
		return nil, err
	}
	var b *Build
	if body != nil {
		b = &Build{}
		if err := json.Unmarshal(body, b); err != nil {
			return nil, fmt.Errorf("parsing build for %s: %w", job, err)
		}
	}
	// Only settled answers (build or 404) are cached, never the error path.
	h.mu.Lock()
	h.latest[job] = b
	h.mu.Unlock()
	return b, nil
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
