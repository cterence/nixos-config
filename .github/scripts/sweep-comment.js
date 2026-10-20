const HEADER = "# Pinned package sweep";

const sectionFor = (system, date, results, trackers) => {
  const trackerByPkg = {};
  for (const line of String(trackers).split("\n")) {
    const m = line.trim().match(/^(\S+)\s+(\S+)\s+(\S+)$/);
    if (m) trackerByPkg[m[1]] = { url: m[2], state: m[3] };
  }
  const rows = String(results)
    .split("\n")
    .filter((line) => line.trim())
    .map((line) => {
      const pkg = line.match(/\|\s*([A-Za-z0-9_.-]+)\s*\|/)?.[1];
      const t = pkg && trackerByPkg[pkg];
      if (t && line.includes("❌")) {
        return stateIsClosed(t.state)
          ? `${line} _(${shortLink(t.url)} merged — pin can be dropped)_`
          : `${line} _(${shortLink(t.url)} still open)_`;
      }
      if (t) {
        return stateIsClosed(t.state)
          ? `${line} _(${shortLink(t.url)} merged)_`
          : `${line} _(${shortLink(t.url)} open)_`;
      }
      return line;
    });
  return [
    `### ${system} — ${date}`,
    "",
    "| Package | Builds on unstable |",
    "| --- | --- |",
    ...rows,
  ].join("\n");
};

const stateIsClosed = (state) => state === "closed" || state === "merged";

const shortLink = (url) => {
  const m = url.match(/github\.com\/NixOS\/nixpkgs\/(pull|issues)\/(\d+)/);
  return m ? `nixpkgs#${m[2]}` : url;
};

const FOOTER = [
  "",
  "Pins are declared in nix source comments (`# pin: <pkg> <version> | tracker: <nixpkgs PR/issue> | reason: <text>`),",
  "resolved via nixpkgs-multiverse `pinOverlay`. When a row turns ✅, drop the matching pin.",
].join("\n");

module.exports = async ({ github, context, core, system, results, trackers }) => {
  if (!String(results).trim()) {
    core.info("no pins to report on");
    return;
  }
  const date = new Date().toISOString().slice(0, 10);
  const section = sectionFor(system, date, results, trackers);

  const { data: prs } = await github.rest.pulls.list({
    owner: context.repo.owner,
    repo: context.repo.repo,
    state: "open",
    per_page: 100,
  });
  const lockPr = prs.find((pr) => /^chore\(flake\.lock\): update/.test(pr.title));

  let issueNumber = lockPr ? lockPr.number : null;
  if (!issueNumber) {
    const { data: issues } = await github.rest.issues.list({
      owner: context.repo.owner,
      repo: context.repo.repo,
      state: "open",
      labels: "pinned-sweep",
      per_page: 1,
    });
    const tracking = issues.find((i) => i.pull_request === undefined);
    if (tracking) {
      issueNumber = tracking.number;
    } else {
      const { data: created } = await github.rest.issues.create({
        owner: context.repo.owner,
        repo: context.repo.repo,
        title: "Pinned package sweep tracker",
        labels: ["pinned-sweep"],
        body: [
          "Tracking issue for the `Pinned package sweep` workflow.",
          "Each run reports whether the multiverse-pinned packages build against current nixos-unstable.",
        ].join("\n"),
      });
      issueNumber = created.number;
    }
  }

  const { data: comments } = await github.rest.issues.listComments({
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: issueNumber,
    per_page: 100,
  });
  const existing = comments.find((c) => c.body.startsWith(HEADER));

  let body;
  if (!existing) {
    body = [HEADER, "", section, FOOTER].join("\n");
  } else {
    const pattern = new RegExp(`### ${system} — [0-9-]+[\\s\\S]*?(?=\\n### |$)`);
    body = pattern.test(existing.body)
      ? existing.body.replace(pattern, section)
      : `${existing.body}\n\n${section}`;
  }

  if (existing) {
    await github.rest.issues.updateComment({
      owner: context.repo.owner,
      repo: context.repo.repo,
      comment_id: existing.id,
      body,
    });
  } else {
    await github.rest.issues.createComment({
      owner: context.repo.owner,
      repo: context.repo.repo,
      issue_number: issueNumber,
      body,
    });
  }
};
