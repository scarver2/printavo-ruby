# spec/printavo/mockup_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Mockup do
  subject(:mockup) { described_class.new(fake_mockup_attrs) }

  it { expect(mockup.id).to be_a(String) }
  it { expect(mockup.url).to be_a(String) }
  it { expect(mockup.position).to be_a(Integer) }
  it { expect(mockup.created_at).to be_a(String) }
end
