---
name: ruby-gem-development
description: Apply printavo-ruby's Ruby gem implementation conventions when changing library code, public APIs, dependencies, documentation, packaging, or developer workflows.
---

# Ruby Gem Development

## Development Contract

- Write library code compatible with the Ruby floor declared by
  `spec.required_ruby_version` in `printavo-ruby.gemspec`, currently Ruby 3.0.
- Use the Ruby versions in `.mise.toml` for local matrix verification. The
  actively tested matrix does not redefine or narrow the public runtime floor.
- Use the canonical project commands: `bin/spec`, `bin/lint`, and `bin/package`.
- Keep code under the `Printavo` namespace and preserve the `printavo-ruby` gem
  identity and `bin/printavo` executable.
- Keep the library independent of Rails and other application frameworks.
- Prefer small objects, explicit dependencies, and instance-owned state. Do not
  add global mutable configuration.

## Public Compatibility

- Treat resource methods, models, lower-level API access, errors, value objects,
  and documented return shapes as public API.
- Preserve backward compatibility unless a reviewed SemVer change explicitly
  authorizes a break.
- Treat raising the required Ruby version as a public compatibility change that
  requires explicit review, SemVer consideration, and changelog documentation.
- Keep runtime dependencies minimal. Document the concrete need for every new
  runtime dependency and prefer Ruby's standard library when it fits.
- Update `docs/CHANGELOG.md`, README/API examples, and relevant docs with public
  behavior or compatibility changes.

## Source Conventions

- Start every source file with its repository-relative path prolog.
- Put `# frozen_string_literal: true` on line 2 of Ruby files.
- Keep requires alphabetized within logical groups unless load order is
  necessary; document non-obvious ordering.
- Keep RuboCop clean and add RSpec coverage for every behavior change.
- Run `bin/package` when changing the gemspec, packaged files, executables,
  runtime dependencies, or release-facing metadata.

Read `AGENTS.md`, `README.md`, and `docs/CONTRIBUTING.md` before changing public
behavior. Use `.skills/printavo-api/SKILL.md` for provider-facing work and
`.skills/testing/SKILL.md` for test boundaries.

—
Stan Carver II
Made in Texas 🤠
https://stancarver.com
