# spec/support/factories/invoice.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_invoice_attrs(overrides = {}) # rubocop:disable Metrics/AbcSize
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'visualId' => Faker::Number.number(digits: 4).to_s,
      'nickname' => Faker::Lorem.word.capitalize,
      'total' => Faker::Commerce.price(range: 50.0..5000.0).to_s,
      'amountPaid' => Faker::Commerce.price(range: 0.0..500.0).to_s,
      'amountOutstanding' => Faker::Commerce.price(range: 0.0..500.0).to_s,
      'paidInFull' => false,
      'invoiceAt' => Faker::Date.backward(days: 30).iso8601,
      'paymentDueAt' => Faker::Date.forward(days: 30).iso8601,
      'createdAt' => Faker::Time.backward(days: 90).iso8601,
      'updatedAt' => Faker::Time.backward(days: 30).iso8601,
      'status' => { 'id' => '3', 'name' => 'Invoice', 'color' => '#009900' },
      'contact' => fake_contact_attrs
    }.merge(overrides.transform_keys(&:to_s))
  end
end
