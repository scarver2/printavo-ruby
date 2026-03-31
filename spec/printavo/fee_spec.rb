# spec/printavo/fee_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Fee do
  subject(:fee) { described_class.new(fake_fee_attrs) }

  it { expect(fee.id).to be_a(String) }
  it { expect(fee.name).to be_a(String) }
  it { expect(fee.amount).to be_a(String) }
  it { expect(fee.taxable).to be false }
  it { expect(fee.taxable?).to be false }

  describe '#taxable?' do
    it 'returns true when taxable is true' do
      expect(described_class.new(fake_fee_attrs('taxable' => true)).taxable?).to be true
    end
  end
end
