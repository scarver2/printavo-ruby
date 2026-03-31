# spec/printavo/approval_request_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::ApprovalRequest do
  subject(:approval_request) { described_class.new(fake_approval_request_attrs) }

  it { expect(approval_request.id).to be_a(String) }
  it { expect(approval_request.status).to be_a(String) }
  it { expect(approval_request.sent_at).to be_a(String) }
  it { expect(approval_request.expires_at).to be_a(String) }

  describe '#contact' do
    it 'returns a Contact instance' do
      expect(approval_request.contact).to be_a(Printavo::Contact)
    end

    it 'returns nil when contact is absent' do
      ar = described_class.new(fake_approval_request_attrs('contact' => nil))
      expect(ar.contact).to be_nil
    end
  end
end
