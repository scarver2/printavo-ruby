---
name: printavo-api
description: Apply printavo-ruby's provider-contract and SDK architecture rules when changing Printavo REST or GraphQL access, resources, models, authentication, pagination, response envelopes, or error handling.
---

# Printavo API

Read `AGENTS.md`, `README.md`, the relevant implementation, and the applicable
Printavo documentation before changing provider behavior.

## Architecture

- Keep the gem framework-agnostic and preserve instance-owned clients,
  connections, credentials, caches, and configuration.
- Preserve the resource/domain layer for ergonomic workflows and lower-level API
  access for unwrapped capabilities.
- Keep REST and GraphQL contracts distinct. Share neutral value objects only
  when their semantics genuinely match.
- Keep GraphQL operations in `lib/printavo/graphql/**/*.graphql`; resources own
  orchestration and models own returned domain data.
- Follow existing cursor and `Printavo::Page` conventions for pagination.

## Trust Boundaries

- Authenticate with the documented Printavo email/token contract. Do not replace
  it with a guessed single `api_key` interface.
- Preserve sanitized error evidence, allowlisted response metadata, immutable
  envelopes/pages, exact response-byte handling, and zero-network replay seams.
- Do not expose request headers, credentials, Faraday environments, connection
  objects, or unsanitized provider data through public errors or ordinary
  inspection.

## Contract Evidence

- Base API behavior on official Printavo documentation or a reproducible,
  sanitized verification. Record the source in public documentation when the
  behavior is provider-specific.
- Do not infer fields, enums, mutations, status behavior, retry safety, or
  pagination semantics from names alone.
- Add focused RSpec coverage for success, partial/malformed responses,
  authentication/transport failures, and data-sanitization boundaries relevant
  to the change.

Primary documentation:

- `https://www.printavo.com/docs/api/v2`
- `https://www.printavo.com/blog/new-graphql-api/`

—
Stan Carver II
Made in Texas 🤠
https://stancarver.com
