# bin/support/release_command.rb
# frozen_string_literal: true

require_relative '../../lib/printavo/version'
require_relative 'release_guard'

root = File.expand_path('../..', __dir__)
repository = Printavo::ReleaseSupport::Repository.new(root)
guard = Printavo::ReleaseSupport::Guard.new(version: Printavo::VERSION, repository: repository)

begin
  case ARGV.fetch(0)
  when 'check'
    check = Printavo::ReleaseSupport::LocalCheck.new(
      guard: guard,
      commands: %w[spec lint package].map { |command| File.join(root, 'bin', command) }
    )
    check.run!
  when 'verify-tag'
    tag = guard.verify_ci!
    puts "Verified #{tag} at current origin/master"
  else
    raise Printavo::ReleaseSupport::Error, 'expected check or verify-tag'
  end
rescue Printavo::ReleaseSupport::Error => e
  warn "ERROR: #{e.message}"
  exit 1
end
