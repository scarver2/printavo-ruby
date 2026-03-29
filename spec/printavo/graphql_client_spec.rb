# spec/printavo/graphql_client_spec.rb
require 'spec_helper'

RSpec.describe Printavo::GraphqlClient do
  let(:connection) { Printavo::Connection.new(email: PRINTAVO_TEST_EMAIL, token: PRINTAVO_TEST_TOKEN).build }
  let(:client)     { described_class.new(connection) }
  let(:query)      { '{ customers { nodes { id } } }' }
  let(:endpoint)   { PRINTAVO_API_URL }

  describe '#query' do
    context 'with a successful response' do
      let(:data) { { 'customers' => { 'nodes' => [{ 'id' => '1' }] } } }

      before do
        stub_request(:post, endpoint)
          .to_return(status: 200, body: { 'data' => data }.to_json,
                     headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the data hash' do
        result = client.query(query)
        expect(result).to eq(data)
      end
    end

    context 'when the API returns 401' do
      before { stub_request(:post, endpoint).to_return(status: 401, body: '') }

      it 'raises AuthenticationError' do
        expect { client.query(query) }.to raise_error(Printavo::AuthenticationError)
      end
    end

    context 'when the API returns 429' do
      before do
        # Stub enough times to satisfy faraday-retry attempts
        stub_request(:post, endpoint).to_return(status: 429, body: '').times(5)
      end

      it 'raises RateLimitError' do
        expect { client.query(query) }.to raise_error(Printavo::RateLimitError)
      end
    end

    context 'when the response contains GraphQL errors' do
      before do
        body = { 'errors' => [{ 'message' => 'Field not found' }] }.to_json
        stub_request(:post, endpoint)
          .to_return(status: 200, body: body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises ApiError with the error message' do
        expect { client.query(query) }.to raise_error(Printavo::ApiError, /Field not found/)
      end
    end
  end
end
