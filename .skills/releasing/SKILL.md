---
name: releasing
description: Use for printavo-ruby version preparation, package verification, release tags, protected-environment approval, RubyGems publication, or release recovery.
---

# Releasing

Read `AGENTS.md` and `docs/RELEASING.md` before any release work.

## Authority Boundary

Passing automated checks is not permission to release. Never create or push a
release tag, approve the protected `release` environment, publish or yank a gem,
or otherwise authorize publication without explicit Sheriff approval for the
specific release.

If approval is absent or ambiguous, stop after non-mutating preparation and
report exactly what remains gated.

## Authoritative Commands

- `bin/release-check` validates a clean, current `master`, an unused tag, the
  supported Ruby test/lint matrix, and the package. It is a dry run.
- `bin/package` builds the gem, verifies exact packaged files, installs it into
  an isolated `GEM_HOME`, and loads it from that installation.
- `bin/verify-release-tag` is the CI guard for tag, version, commit, and current
  `origin/master` agreement.

Do not replace these commands with ad hoc equivalents. When changing release
behavior, update the commands, their specs, the GitHub workflow, and
`docs/RELEASING.md` together.

## Release Invariants

- Release only reviewed commits reachable as current `origin/master`.
- Require a clean checkout, a matching stable `vMAJOR.MINOR.PATCH` tag, updated
  version/changelog/lockfile, green CI, verified package contents, and the
  protected human approval.
- Push only the reviewed release tag; never use a broad `--tags` push.
- Never move, reuse, or overwrite a published version tag. Correct defects with
  a new patch release; yank only with explicit Sheriff approval and documented
  cause.
- Verify the GitHub workflow, GitHub release, and RubyGems version after an
  authorized publication.

—
Stan Carver II
Made in Texas 🤠
https://stancarver.com
