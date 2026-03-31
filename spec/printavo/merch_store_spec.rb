# spec/printavo/merch_store_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::MerchStore do
  subject(:store) { described_class.new(fake_merch_store_attrs) }

  it { expect(store.id).to be_a(String) }
  it { expect(store.name).to be_a(String) }
  it { expect(store.url).to be_a(String) }
  it { expect(store.summary).to be_a(Hash) }
end
