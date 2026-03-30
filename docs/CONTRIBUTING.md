<!-- docs/CONTRIBUTING.md -->
# Contributing to printavo-ruby

Thank you for your interest in contributing! This guide covers setup, workflow,
and standards for working on `printavo-ruby`.

## Setup

```bash
git clone https://github.com/scarver2/printavo-ruby.git
cd printavo-ruby
bundle install
```

## Running Tests

```bash
bundle exec rspec
```

Coverage is tracked via SimpleCov. The minimum threshold is **90%**.
New code must include specs.

## Guard DX (Recommended)

Guard watches for file changes and re-runs specs and RuboCop automatically:

```bash
bundle exec guard
```

## Coding Standards

This project uses [RuboCop](https://rubocop.org/) with the
`rubocop-performance`, `rubocop-rake`, and `rubocop-rspec` extensions.

```bash
bundle exec rubocop
bundle exec rubocop -a   # auto-correct safe offenses
```

## VCR Cassettes

Integration tests use [VCR](https://github.com/vcr/vcr) to record and replay
HTTP interactions. All cassettes **must be sanitized** before committing:

- Real email addresses → `customer@example.com`
- Real phone numbers → `555-867-5309`
- Real customer names → `Acme Customer`
- API credentials are filtered automatically by `spec/support/vcr.rb`

Use the A1Web demo Printavo account when recording new cassettes — never
record against production TER data.

## Pull Request Guidelines

- Branch from `master`
- One feature / bug fix per PR
- All CI checks must pass (RSpec + RuboCop across Ruby 3.1–4.0)
- Write specs for any new code
- Update `docs/CHANGELOG.md` with a summary of changes

## Version Bump Rules

Versions follow [Semantic Versioning](https://semver.org/):

| Change type | Version part |
|---|---|
| Bug fix | PATCH (0.1.x) |
| New backward-compatible feature | MINOR (0.x.0) |
| Breaking API change | MAJOR (x.0.0) |

Bump `lib/printavo/version.rb`, update `docs/CHANGELOG.md`, then:

```bash
git commit -am "Release vX.Y.Z"
git tag vX.Y.Z
git push origin master --tags
```

GitHub Actions will build and push to RubyGems automatically on tag push.

---

## Colophon

[MIT License](LICENSE)

&copy;2026 [Stan Carver II](https://stancarver.com)

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
