# spec/printavo/line_item_group_pricing_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::LineItemGroupPricing do
  subject(:pricing) do
    described_class.new('defaultMarkupPercentage' => 25.0, 'description' => 'Matrix price',
                        'price' => 12.5, 'signature' => 'signed')
  end

  it 'exposes the documented pricing receipt fields' do
    expect(pricing.default_markup_percentage).to eq(25.0)
    expect(pricing.description).to eq('Matrix price')
    expect(pricing.price).to eq(12.5)
    expect(pricing.signature).to eq('signed')
  end
end
