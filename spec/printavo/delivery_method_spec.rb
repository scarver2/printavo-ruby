# spec/printavo/delivery_method_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::DeliveryMethod do
  subject(:delivery_method) { described_class.new(fake_delivery_method_attrs) }

  it { expect(delivery_method.id).to be_a(String) }
  it { expect(delivery_method.name).to be_a(String) }
end
