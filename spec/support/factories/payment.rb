# spec/support/factories/payment.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_payment_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'amount' => Faker::Commerce.price(range: 10.0..5000.0).to_s,
      'paymentMethod' => %w[cash check credit_card].sample,
      'paidAt' => Faker::Time.backward(days: 30).iso8601
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_payment_request_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'amount' => Faker::Commerce.price(range: 10.0..5000.0).to_s,
      'sentAt' => Faker::Time.backward(days: 14).iso8601,
      'paidAt' => nil,
      'details' => nil
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_payment_term_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => "Net #{[15, 30, 45, 60].sample}",
      'netDays' => [15, 30, 45, 60].sample
    }.merge(overrides.transform_keys(&:to_s))
  end
end
