const HEADER = "# Pinned package sweep";

const upstreamHint = (pkg, state) => {
  if (pkg === "calibre") {
    return state === "closed"
      ? "nixpkgs#576063 merged — pin can be dropped"
      : "tracked in https://github.com/NixOS/nixpkgs/pull/576063";
  }
  if (pkg === "qbittorrent") {
    return state === "closed"
      ? "nixpkgs#576182 closed — pin can be dropped"
      : "tracked in https://github.com/NixOS/nixpkgs/issues/576182";
  }
  return "";
};

const sectionFor = (system, date, results, pyopenjtalk, qbittorrentDarwin) => {
  const rows = String(results)
    .split("\n")
    .filter((line) => line.trim())
    .map((line) => {
      const pkg = line.includes("qbittorrent")
        ? "qbittorrent"
        : line.includes("calibre")
          ? "calibre"
          : null;
      const state = pkg === "calibre" ? pyopenjtalk : qbittorrentDarwin;
      const hint = line.includes("❌") && pkg ? ` _(${upstreamHint(pkg, state)})_` : "";
      return `${line}${hint}`;
    });
  return [
    `### ${system} — ${date}`,
    "",
    "| Package | Builds on unstable |",
    "| --- | --- |",
    ...rows,
  ].join("\n");
};

const FOOTER = [
  "",
  "Pins live in `modules/programs/desktop-apps.nix` (nixpkgs-multiverse `pinOverlay`).",
  "When a row turns ✅, drop the matching pin there.",
].join("\n");

module.exports = async ({ github, context, core, system, results, pyopenjtalk, qbittorrentDarwin }) => {
  const date = new Date().toISOString().slice(0, 10);
  const section = sectionFor(system, date, results, pyopenjtalk, qbittorrentDarwin);

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
          "Each run reports whether the multiverse-pinned packages (see `modules/programs/desktop-apps.nix`) build against current nixos-unstable.",
          "When a row turns ✅, drop the matching pin there.",
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
