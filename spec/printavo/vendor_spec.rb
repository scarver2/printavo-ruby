# spec/printavo/vendor_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Vendor do
  subject(:vendor) { described_class.new(fake_vendor_attrs) }

  it { expect(vendor.id).to be_a(String) }
  it { expect(vendor.name).to be_a(String) }
  it { expect(vendor.email).to be_a(String) }
  it { expect(vendor.phone).to be_a(String) }
end
