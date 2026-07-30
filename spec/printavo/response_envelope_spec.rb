# spec/printavo/response_envelope_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::ResponseEnvelope do
  subject(:envelope) do
    described_class.new(
      data: { 'contact' => { 'id' => '123' } },
      errors: [{ 'message' => 'Partial result' }],
      metadata: { 'x-request-id' => 'request-1' }
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
end
