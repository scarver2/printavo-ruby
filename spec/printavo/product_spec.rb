# spec/printavo/product_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Product do
  subject(:product) { described_class.new(fake_product_attrs) }

  it { expect(product.id).to be_a(String) }
  it { expect(product.name).to be_a(String) }
  it { expect(product.sku).to be_a(String) }
  it { expect(product.description).to be_a(String) }
end
