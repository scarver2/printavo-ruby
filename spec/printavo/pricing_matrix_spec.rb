# spec/printavo/pricing_matrix_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::PricingMatrix do
  subject(:matrix) { described_class.new(fake_pricing_matrix_attrs) }

  it { expect(matrix.id).to be_a(String) }
  it { expect(matrix.name).to be_a(String) }
end
