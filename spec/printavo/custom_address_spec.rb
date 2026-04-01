# spec/printavo/custom_address_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::CustomAddress do
  subject(:custom_address) { described_class.new(fake_custom_address_attrs) }

  it { expect(custom_address.id).to be_a(String) }
  it { expect(custom_address.name).to be_a(String) }
  it { expect(custom_address.address).to be_a(String) }
  it { expect(custom_address.city).to be_a(String) }
  it { expect(custom_address.state).to be_a(String) }
  it { expect(custom_address.zip).to be_a(String) }
  it { expect(custom_address.country).to be_a(String) }
end
