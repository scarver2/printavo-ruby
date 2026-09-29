<!-- AGENTS.md -->
# Agent Execution Contract

This file is the repository-level contract for automated contributors working
on `printavo-ruby`. It supplements machine-wide policy and applies to the entire
repository.

## Read Before Changing Behavior

Before modifying public behavior, read this file, the applicable repository
skills under `.skills/`, `README.md`, `docs/CONTRIBUTING.md`, and the relevant
Printavo API documentation. Treat documented or directly verified provider
behavior as authoritative; never invent an API contract from naming patterns or
assumptions.

## Product And Architecture

- Support Ruby 3.3 and newer through the CI matrix and `.mise.toml`.
- Keep this gem framework-agnostic. Do not introduce Rails-only code or runtime
  dependencies.
- Preserve both public layers: ergonomic resources/domain models and lower-level
  API access for capabilities that do not yet have resource wrappers.
- Treat REST and GraphQL as distinct, first-class Printavo interfaces whenever
  work touches either contract. Do not force one interface's semantics onto the
  other.
- Preserve instance-based, multi-client operation. Never introduce global
  mutable configuration, credential state, or connection singletons.
- Preserve the `Printavo` namespace and the `printavo-ruby` package identity.
- Keep runtime dependencies modest and justify each addition against a concrete
  public requirement.

## Canonical Workflows

Project-local `bin/*` commands are authoritative. Prefer them over reconstructed
command sequences:

- `bin/spec [arguments]` for the supported Ruby test matrix;
- `bin/lint [arguments]` for the supported Ruby lint matrix;
- `bin/package` for exact package inspection and isolated installation; and
- `bin/release-check` for a non-publishing release dry run.

When a task adds a new canonical workflow, expose it through `bin/*` and reuse
that command from CI rather than implementing a second path in workflow YAML.

## Tests And Sensitive Data

- RSpec is the test language. Every behavior change requires focused specs,
  including meaningful failure paths.
- Keep SimpleCov at or above the repository threshold and keep RuboCop clean.
- Use WebMock and VCR at HTTP boundaries and Faker-generated identities in test
  data and recordings.
- Treat VCR cassettes as potentially sensitive. Sanitize them before commit and
  never commit Printavo credentials, real Texas Embroidery Ranch customer data,
  or other private provider payloads.

## Source, Documentation, And Compatibility

- Every source file starts with its repository-relative path prolog; Ruby files
  put `# frozen_string_literal: true` on line 2.
- Follow SemVer. Update `docs/CHANGELOG.md` and relevant public documentation
  whenever public behavior or compatibility changes.
- Link to the relevant Printavo documentation when documenting provider-specific
  behavior.
- Preserve the MIT license, ownership, backlinks, and established documentation
  footer.

## Git And Release Authority

- `master` is the protected canonical branch. Work on purpose-named branches and
  deliver changes through pull requests.
- Never bypass hooks, CI, review, or branch protection.
- Never publish a gem, create or push a release tag, approve a protected release
  environment, or otherwise authorize a release without explicit Sheriff
  approval for that release.
- Passing `bin/release-check`, `bin/package`, CI, or any other automated gate is
  evidence only; it is never release authorization.

## Repository Skills

- `.skills/printavo-api/SKILL.md` for provider contracts and SDK architecture.
- `.skills/ruby-gem-development/SKILL.md` for implementation and compatibility.
- `.skills/testing/SKILL.md` for specs, coverage, and sanitized HTTP fixtures.
- `.skills/releasing/SKILL.md` for packaging and human-gated publication.

—
Stan Carver II
Made in Texas 🤠
https://stancarver.com
