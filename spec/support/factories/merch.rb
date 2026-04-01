# spec/support/factories/merch.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_merch_store_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Company.name,
      'url' => Faker::Internet.url,
      'summary' => { 'totalOrders' => Faker::Number.between(from: 0, to: 500),
                     'totalRevenue' => Faker::Commerce.price(range: 0.0..50_000.0).to_s }
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_merch_order_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'status' => Printavo::Enums::MerchOrderStatus::ALL.sample,
      'contact' => fake_contact_attrs,
      'delivery' => { 'method' => Printavo::Enums::MerchOrderDeliveryMethod::DELIVERY,
                      'trackingNumber' => nil, 'shippedAt' => nil }
    }.merge(overrides.transform_keys(&:to_s))
  end
end
