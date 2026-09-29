# spec/printavo/release_support/repository_spec.rb
# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../bin/support/release_guard'

RSpec.describe Printavo::ReleaseSupport::Repository do
  let(:status_class) { Struct.new(:success?) }
  let(:success) { status_class.new(true) }
  let(:responses) { {} }
  let(:capture) do
    lambda do |_command, *arguments, chdir:| # rubocop:disable Lint/UnusedBlockArgument
      responses.fetch(arguments)
    end
  end
  let(:repository) { described_class.new('/project', capture: capture) }

  it 'reads the current branch' do
    responses[%w[branch --show-current]] = ["master\n", '', success]

    expect(repository.branch).to eq('master')
  end

  it 'reports a clean repository' do
    responses[%w[status --porcelain --untracked-files=all]] = ['', '', success]

    expect(repository).to be_clean
  end

  it 'reads the peeled HEAD commit' do
    responses[%w[rev-parse HEAD^{commit}]] = ["abc123\n", '', success]

    expect(repository.head).to eq('abc123')
  end

  it 'reads current master directly from origin' do
    responses[%w[ls-remote origin refs/heads/master]] = ["abc123\trefs/heads/master\n", '', success]

    expect(repository.remote_master).to eq('abc123')
  end

  it 'reports dirty state and missing remote refs' do
    responses[%w[status --porcelain --untracked-files=all]] = [" M README.md\n", '', success]
    responses[%w[ls-remote origin refs/tags/v0.21.0]] = ['', '', success]

    expect(repository).not_to be_clean
    expect(repository.remote_tag_exists?('v0.21.0')).to be(false)
  end

  it 'reports existing remote and local tags' do
    responses[%w[ls-remote origin refs/tags/v0.21.0]] = ["abc123\trefs/tags/v0.21.0\n", '', success]
    responses[%w[rev-list -n 1 refs/tags/v0.21.0]] = ["abc123\n", '', success]

    expect(repository.remote_tag_exists?('v0.21.0')).to be(true)
    expect(repository.tag_commit('v0.21.0')).to eq('abc123')
  end

  it 'returns nil when a local tag does not exist' do
    responses[%w[rev-list -n 1 refs/tags/v0.21.0]] = ['', 'missing', status_class.new(false)]

    expect(repository.tag_commit('v0.21.0')).to be_nil
  end

  it 'raises a useful error when a Git command fails' do
    responses[%w[branch --show-current]] = ['', "fatal: unavailable\n", status_class.new(false)]

    expect { repository.branch }.to raise_error(
      Printavo::ReleaseSupport::Error,
      'git branch --show-current failed: fatal: unavailable'
    )
  end

  it 'supplies a fallback when Git writes no error detail' do
    responses[%w[branch --show-current]] = ['', '', status_class.new(false)]

    expect { repository.branch }.to raise_error(Printavo::ReleaseSupport::Error, /unknown Git error/)
  end
end
