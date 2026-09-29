# spec/printavo/release_support/local_check_spec.rb
# frozen_string_literal: true

require 'spec_helper'

require 'stringio'
require_relative '../../../bin/support/release_guard'

RSpec.describe Printavo::ReleaseSupport::LocalCheck do
  let(:guard) { instance_double(Printavo::ReleaseSupport::Guard) }
  let(:runner) { instance_double(Method) }
  let(:output) { StringIO.new }
  let(:commands) { ['/project/bin/spec', '/project/bin/lint', '/project/bin/package'] }
  let(:check) { described_class.new(guard: guard, commands: commands, runner: runner, output: output) }

  it 'rechecks repository state after every command succeeds' do
    allow(guard).to receive(:verify_local!).and_return('v0.21.0')
    allow(runner).to receive(:call).and_return(true)

    expect(check.run!).to eq('v0.21.0')
    expect(guard).to have_received(:verify_local!).twice
    expect(runner).to have_received(:call).exactly(3).times
  end

  it 'stops before the final state check when a command fails' do
    allow(guard).to receive(:verify_local!).and_return('v0.21.0')
    allow(runner).to receive(:call).with(commands.first).and_return(false)

    expect { check.run! }.to raise_error(Printavo::ReleaseSupport::Error, 'spec failed')
    expect(guard).to have_received(:verify_local!).once
  end
end
