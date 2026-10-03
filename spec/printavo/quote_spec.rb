# spec/printavo/quote_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Quote do
  subject(:quote) { described_class.new(attributes) }

  let(:attributes) do
    fake_order_attrs.reject { |key,| key == 'updatedAt' }.merge(
      'total' => '125.50',
      'contact' => fake_contact_attrs,
      'timestamps' => { 'updatedAt' => '2026-10-03T12:00:00Z' }
    )
  end

  it 'exposes the documented quote total' do
    expect(quote.total).to eq('125.50')
    expect(quote.total_price).to eq('125.50')
  end

  it 'wraps its contact' do
    expect(quote.contact).to be_a(Printavo::Contact)
  end

  it 'maps the documented nested update timestamp' do
    expect(quote.updated_at).to eq('2026-10-03T12:00:00Z')
  end
end
