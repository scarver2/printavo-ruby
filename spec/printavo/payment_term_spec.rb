# spec/printavo/payment_term_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::PaymentTerm do
  subject(:payment_term) { described_class.new(fake_payment_term_attrs) }

  it { expect(payment_term.id).to be_a(String) }
  it { expect(payment_term.name).to be_a(String) }
  it { expect(payment_term.net_days).to be_a(Integer) }
end
