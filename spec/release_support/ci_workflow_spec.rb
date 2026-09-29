# spec/release_support/ci_workflow_spec.rb
# frozen_string_literal: true

require 'spec_helper'

# A workflow is executable configuration rather than a Ruby class.
# rubocop:disable RSpec/DescribeClass
RSpec.describe 'CI workflow' do
  subject(:workflow) { File.read(File.expand_path('../../.github/workflows/ci.yml', __dir__)) }

  let(:mise_config) { File.read(File.expand_path('../../.mise.toml', __dir__)) }

  it 'tests Ruby 3.3, 3.4, and 4.0' do
    expect(workflow).to include('- "3.3"', '- "3.4"', '- "4.0"')
  end

  it 'keeps the CI minors aligned with the local mise matrix' do
    ci_minors = workflow.scan(/^\s+- "(\d+\.\d+)"$/).flatten
    mise_minors = mise_config.scan(/"(\d+\.\d+)\.\d+"/).flatten

    expect(ci_minors).to match_array(mise_minors)
  end
end
# rubocop:enable RSpec/DescribeClass
