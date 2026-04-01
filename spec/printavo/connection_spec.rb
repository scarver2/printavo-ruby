# spec/printavo/connection_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Connection do
  subject(:connection) do
    described_class.new(email: 'test@example.com', token: 'abc123')
  end

  describe '#build' do
    subject(:conn) { connection.build }

    it 'returns a Faraday::Connection' do
      expect(conn).to be_a(Faraday::Connection)
    end

    it 'sets the email header' do
      expect(conn.headers['email']).to eq('test@example.com')
    end

    it 'sets the token header' do
      expect(conn.headers['token']).to eq('abc123')
    end

    it 'sets the Content-Type header' do
      expect(conn.headers['Content-Type']).to eq('application/json')
    end

    it 'includes the retry middleware' do
      handler_names = conn.builder.handlers.map { |h| h.klass.name }
      expect(handler_names).to include('Faraday::Retry::Middleware')
    end
  end

  describe 'retry configuration' do
    it 'accepts a custom max_retries value' do
      conn = described_class.new(email: 'e', token: 't', max_retries: 5)
      expect { conn.build }.not_to raise_error
    end

    it 'includes 429 in retry statuses by default (retry_on_rate_limit: true)' do
      conn = described_class.new(email: 'e', token: 't', retry_on_rate_limit: true)
      expect { conn.build }.not_to raise_error
    end

    it 'excludes 429 from retry statuses when retry_on_rate_limit: false' do
      conn = described_class.new(email: 'e', token: 't', retry_on_rate_limit: false)
      expect { conn.build }.not_to raise_error
    end
  end
end
