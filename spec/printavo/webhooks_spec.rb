# spec/printavo/webhooks_spec.rb
require 'spec_helper'
require 'openssl'

RSpec.describe Printavo::Webhooks do
  let(:secret)  { 'super_secret_webhook_key' }
  let(:payload) { '{"event":"order.created","id":"123"}' }
  let(:valid_signature) do
    OpenSSL::HMAC.hexdigest('SHA256', secret, payload)
  end

  describe '.verify' do
    it 'returns true for a valid signature' do
      expect(described_class.verify(valid_signature, payload, secret)).to be true
    end

    it 'returns false for an invalid signature' do
      expect(described_class.verify('bad_signature', payload, secret)).to be false
    end

    it 'returns false when signature is nil' do
      expect(described_class.verify(nil, payload, secret)).to be false
    end

    it 'returns false when payload is nil' do
      expect(described_class.verify(valid_signature, nil, secret)).to be false
    end

    it 'returns false when secret is nil' do
      expect(described_class.verify(valid_signature, payload, nil)).to be false
    end

    it 'returns false for a tampered payload' do
      tampered = payload.sub('123', '456')
      expect(described_class.verify(valid_signature, tampered, secret)).to be false
    end

    it 'returns false when signature is a non-string type (triggers rescue)' do
      # OpenSSL.secure_compare requires two strings; an Integer raises TypeError
      expect(described_class.verify(12_345, payload, secret)).to be false
    end
  end
end
