# spec/printavo/payment_request_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::PaymentRequest do
  subject(:payment_request) { described_class.new(fake_payment_request_attrs) }

  it { expect(payment_request.id).to be_a(String) }
  it { expect(payment_request.amount).to be_a(String) }
  it { expect(payment_request.sent_at).to be_a(String) }
  it { expect(payment_request.paid_at).to be_nil }
  it { expect(payment_request.details).to be_nil }
end
