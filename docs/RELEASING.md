<!-- docs/RELEASING.md -->
# Releasing printavo-ruby

Releases are published to RubyGems through GitHub Actions trusted publishing.
No local RubyGems API key is required or accepted by the release workflow.

## Prepare the release

1. Update `lib/printavo/version.rb` with the new semantic version.
2. Add the dated release notes to `docs/CHANGELOG.md`.
3. Run `bundle install` so `Gemfile.lock` records the same gem version.
4. Submit the release through a pull request and merge it into `master` only
   after CI and review pass.

## Validate the release source

From a clean, up-to-date `master` checkout, run:

```bash
git fetch origin master --tags
git switch master
git pull --ff-only origin master
bin/release-check
```

`bin/release-check` refuses to proceed unless:

- the checkout is clean and on `master`;
- `HEAD` equals the current `origin/master` commit;
- `Printavo::VERSION` is a stable `MAJOR.MINOR.PATCH` version;
- the matching `vMAJOR.MINOR.PATCH` tag is unused locally and remotely; and
- the multi-Ruby specs, lint checks, and isolated package verification pass.

The command is a dry run. It never creates a tag or publishes a gem.

## Trigger publication

After reviewing the dry-run output, create an annotated tag at the verified
commit and push only that tag:

```bash
version="$(mise exec -- ruby -Ilib -rprintavo/version -e 'print Printavo::VERSION')"
git tag -a "v${version}" -m "Release v${version}"
git push origin "refs/tags/v${version}"
```

The release workflow independently verifies that the tag matches the gem
version, points to the checked-out commit, and equals current `origin/master`.
It then reruns tests, lint, and package verification before pausing at the
protected `release` environment. Approve that deployment in GitHub Actions to
publish through RubyGems OIDC trusted publishing.

## Verify publication

Confirm all three release surfaces:

1. the GitHub Actions `Release` workflow completed successfully;
2. the GitHub release exists for the new tag; and
3. RubyGems lists the new version at
   `https://rubygems.org/gems/printavo-ruby/versions`.

Never move or reuse a published version tag. If a published gem is defective,
prepare a new patch release. Yank a version only when the release itself is
unsafe to install and document the reason in the changelog and GitHub release.

—
Stan Carver II
Made in Texas 🤠
https://stancarver.com
