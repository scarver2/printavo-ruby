# bin/support/release_guard.rb
# frozen_string_literal: true

require 'open3'

module Printavo
  module ReleaseSupport
    class Error < StandardError; end

    # Provides the read-only Git facts used to authorize a release source.
    class Repository
      def initialize(root, capture: Open3.method(:capture3))
        @root = root
        @capture = capture
      end

      def branch
        output!('branch', '--show-current')
      end

      def clean?
        output!('status', '--porcelain', '--untracked-files=all').empty?
      end

      def head
        output!('rev-parse', 'HEAD^{commit}')
      end

      def remote_master
        remote_ref('refs/heads/master')
      end

      def remote_tag_exists?(tag)
        !remote_ref("refs/tags/#{tag}").nil?
      end

      def tag_commit(tag)
        output, _, status = capture('rev-list', '-n', '1', "refs/tags/#{tag}")
        status.success? ? output.strip : nil
      end

      private

      def remote_ref(ref)
        output = output!('ls-remote', 'origin', ref)
        output.empty? ? nil : output.split.first
      end

      def output!(*arguments)
        output, error, status = capture(*arguments)
        return output.strip if status.success?

        detail = error.strip
        detail = 'unknown Git error' if detail.empty?
        raise Error, "git #{arguments.join(' ')} failed: #{detail}"
      end

      def capture(*arguments)
        @capture.call('git', *arguments, chdir: @root)
      end
    end

    # Rejects release attempts unless version, tag, commit, and repository state agree.
    class Guard
      NUMBER = '(?:0|[1-9]\d*)'
      TAG_PATTERN = /\Av#{NUMBER}\.#{NUMBER}\.#{NUMBER}\z/

      def initialize(version:, repository:, environment: ENV)
        @version = version
        @repository = repository
        @environment = environment
      end

      def verify_ci!
        check(environment['GITHUB_EVENT_NAME'] == 'push', 'release workflow requires a push event')
        check(environment['GITHUB_REF_TYPE'] == 'tag', 'release workflow requires a tag ref')

        tag = environment.fetch('GITHUB_REF_NAME', '')
        validate_tag!(tag)
        check(tag == expected_tag, "tag must match gem version: #{expected_tag}")
        verify_repository!(tag)
        tag
      end

      def verify_local!
        validate_tag!(expected_tag)
        verify_local_source!
        verify_unused_tag!
        expected_tag
      end

      private

      attr_reader :environment, :repository, :version

      def expected_tag
        "v#{version}"
      end

      def validate_tag!(tag)
        check(TAG_PATTERN.match?(tag), 'tag must use vMAJOR.MINOR.PATCH without leading zeroes')
      end

      def verify_repository!(tag)
        check(repository.clean?, 'release checks require a clean working tree')
        check(repository.tag_commit(tag) == repository.head, 'release tag must point to checked-out HEAD')
        verify_master!
      end

      def verify_master!
        check(repository.head == repository.remote_master, 'release commit must equal current origin/master')
      end

      def verify_local_source!
        check(repository.clean?, 'release checks require a clean working tree')
        check(repository.branch == 'master', 'release checks must run from master')
        verify_master!
      end

      def verify_unused_tag!
        check(repository.tag_commit(expected_tag).nil?, "tag already exists locally: #{expected_tag}")
        check(!repository.remote_tag_exists?(expected_tag), "tag already exists on origin: #{expected_tag}")
      end

      def check(condition, message)
        raise Error, message unless condition
      end
    end

    # Runs local validation between two repository-state checks without publishing.
    class LocalCheck
      def initialize(guard:, commands:, runner: Kernel.method(:system), output: $stdout)
        @guard = guard
        @commands = commands
        @runner = runner
        @output = output
      end

      def run!
        tag = guard.verify_local!
        output.puts "Validated clean release source for #{tag}"
        commands.each { |command| run_command!(command) }
        guard.verify_local!
        output.puts "Dry run passed; reviewed master may be tagged #{tag}"
        output.puts 'No tag was created and no gem was published'
        tag
      end

      private

      attr_reader :commands, :guard, :output, :runner

      def run_command!(command)
        raise Error, "#{File.basename(command)} failed" unless runner.call(command)
      end
    end
  end
end
