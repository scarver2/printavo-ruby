# spec/support/factories/transaction.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_transaction_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'amount' => Faker::Commerce.price(range: 10.0..5000.0).to_s,
      'kind' => %w[payment refund credit].sample,
      'createdAt' => Faker::Time.backward(days: 30).iso8601
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_transaction_payment_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'amount' => Faker::Commerce.price(range: 10.0..5000.0).to_s,
      'paymentMethod' => %w[cash check credit_card].sample,
      'paidAt' => Faker::Time.backward(days: 14).iso8601,
      'note' => nil
    }.merge(overrides.transform_keys(&:to_s))
  end
end
