# spec/printavo/imprint_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Imprint do
  subject(:imprint) { described_class.new(fake_imprint_attrs) }

  it { expect(imprint.id).to be_a(String) }
  it { expect(imprint.name).to be_a(String) }
  it { expect(imprint.position).to be_a(String) }
  it { expect(imprint.colors).to be_a(Integer) }
end
