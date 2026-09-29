---
name: testing
description: Apply printavo-ruby's RSpec, coverage, HTTP-stubbing, fixture-sanitization, and sensitive-data rules when adding, changing, or debugging tests.
---

# Testing

## Required Stack

- Write RSpec, not Minitest.
- Use `bin/spec [arguments]` for the actively exercised Ruby matrix; do not
  interpret that matrix as narrowing the gemspec's public Ruby floor.
- Use `bin/lint [arguments]` for lint verification.
- Keep SimpleCov at or above the configured project threshold; full-suite
  coverage is the release signal, while focused runs may fail the global gate.
- Test observable contracts and important failure paths, not implementation
  trivia.

## HTTP And Provider Data

- Use WebMock for deterministic HTTP boundaries and VCR only when a recording
  materially improves contract coverage.
- Treat every cassette and raw provider payload as potentially sensitive.
- Use Faker-generated identities and sanitized fixtures. Never commit Printavo
  credentials, real Texas Embroidery Ranch customer information, or other
  private provider data.
- Verify cassettes contain no secrets or real identities before commit, even
  when automatic filtering is configured.
- Exercise relevant authentication, rate-limit, transport, malformed-response,
  partial-data, pagination, immutability, redaction, and replay behavior.

## Test Shape

- Require `spec_helper` explicitly.
- Keep factories and support helpers deterministic and narrowly scoped.
- Prefer assertions on public behavior and security boundaries.
- Add regression coverage before fixing a defect when practical.
- Run the entire suite and RuboCop before handoff; report any skipped matrix
  runtime or verification explicitly.

Use `.skills/printavo-api/SKILL.md` when a test encodes provider semantics.

—
Stan Carver II
Made in Texas 🤠
https://stancarver.com
