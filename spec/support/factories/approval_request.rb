# spec/support/factories/approval_request.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_approval_request_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'status' => Printavo::Enums::ApprovalRequestStatus::ALL.sample,
      'sentAt' => Faker::Time.backward(days: 7).iso8601,
      'expiresAt' => Faker::Time.forward(days: 7).iso8601,
      'contact' => fake_contact_attrs
    }.merge(overrides.transform_keys(&:to_s))
  end
end
