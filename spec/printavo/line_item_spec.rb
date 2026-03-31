# spec/printavo/line_item_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::LineItem do
  subject(:line_item) { described_class.new(fake_line_item_attrs) }

  it { expect(line_item.id).to be_a(String) }
  it { expect(line_item.name).to be_a(String) }
  it { expect(line_item.quantity).to be_a(Integer) }
  it { expect(line_item.price).to be_a(String) }
  it { expect(line_item.taxable).to be false }
  it { expect(line_item.taxable?).to be false }

  describe '#taxable?' do
    it 'returns true when taxable is true' do
      expect(described_class.new(fake_line_item_attrs('taxable' => true)).taxable?).to be true
    end
  end
end
