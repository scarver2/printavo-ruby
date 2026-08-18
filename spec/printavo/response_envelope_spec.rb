# spec/printavo/response_envelope_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::ResponseEnvelope do
  subject(:envelope) do
    described_class.new(
      data: { 'contact' => { 'id' => '123' } },
      errors: [{ 'message' => 'Partial result' }],
      metadata: { 'x-request-id' => 'request-1' },
      response_payload: '{ "data" : {"contact":{"id":"123"}} }'
    )
  end

  it 'freezes the envelope and top-level evidence' do
    expect(envelope).to be_frozen
    expect(envelope.data).to be_frozen
    expect(envelope.errors).to be_frozen
    expect(envelope.metadata).to be_frozen
  end

  it 'deeply freezes nested evidence' do
    expect(envelope.data.fetch('contact')).to be_frozen
    expect(envelope.errors.first).to be_frozen
  end

  it 'identifies partial responses' do
    expect(envelope).to be_partial
    expect(envelope).not_to be_success
  end

  it 'exposes an immutable hash without transport objects' do
    expect(envelope.to_h).to eq(
      'data' => { 'contact' => { 'id' => '123' } },
      'errors' => [{ 'message' => 'Partial result' }],
      'metadata' => { 'x-request-id' => 'request-1' }
    )
    expect(envelope.to_h).to be_frozen
  end

  it 'exposes exact immutable binary response bytes only through the explicit reader' do
    expect(envelope.response_payload).to eq('{ "data" : {"contact":{"id":"123"}} }')
    expect(envelope.response_payload.encoding).to eq(Encoding::BINARY)
    expect(envelope.response_payload).to be_frozen
    expect { envelope.response_payload << 'changed' }.to raise_error(FrozenError)
  end

  it 'keeps private response bytes out of ordinary serialization and inspection' do
    expect(envelope.to_h.to_s).not_to include('response_payload')
    expect(envelope.inspect).not_to include('{ "data"')
  end

  it 'rejects non-string response payloads' do
    expect { described_class.new(data: {}, response_payload: {}) }
      .to raise_error(ArgumentError, 'response_payload must be a String')
  end
end
