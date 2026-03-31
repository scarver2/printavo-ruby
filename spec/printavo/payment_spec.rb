# spec/printavo/payment_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Payment do
  subject(:payment) { described_class.new(fake_payment_attrs) }

  it { expect(payment.id).to be_a(String) }
  it { expect(payment.amount).to be_a(String) }
  it { expect(payment.payment_method).to be_a(String) }
  it { expect(payment.paid_at).to be_a(String) }
end
