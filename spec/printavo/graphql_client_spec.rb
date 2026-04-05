# spec/printavo/graphql_client_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::GraphqlClient do
  let(:connection) { Printavo::Connection.new(email: PRINTAVO_TEST_EMAIL, token: PRINTAVO_TEST_TOKEN).build }
  let(:client)     { described_class.new(connection) }
  let(:query)      { '{ customers { nodes { id } } }' }
  let(:endpoint)   { PRINTAVO_API_URL }

  def stub_success(data)
    stub_request(:post, endpoint)
      .to_return(status: 200, body: { 'data' => data }.to_json,
                 headers: { 'Content-Type' => 'application/json' })
  end

  describe '#query' do
    let(:data) { { 'customers' => { 'nodes' => [{ 'id' => '1' }] } } }

    before { stub_success(data) }

    it 'returns the data hash' do
      expect(client.query(query)).to eq(data)
    end

    context 'when the API returns 401' do
      before { stub_request(:post, endpoint).to_return(status: 401, body: '') }

      it 'raises AuthenticationError' do
        expect { client.query(query) }.to raise_error(Printavo::AuthenticationError)
      end
    end

    context 'when the API returns 429' do
      before { stub_request(:post, endpoint).to_return(status: 429, body: '').times(5) }

      it 'raises RateLimitError' do
        expect { client.query(query) }.to raise_error(Printavo::RateLimitError)
      end
    end

    context 'when the API returns 404' do
      before { stub_request(:post, endpoint).to_return(status: 404, body: '') }

      it 'raises NotFoundError' do
        expect { client.query(query) }.to raise_error(Printavo::NotFoundError)
      end
    end

    context 'when the response contains GraphQL errors' do
      before do
        stub_request(:post, endpoint)
          .to_return(status: 200,
                     body: { 'errors' => [{ 'message' => 'Field not found' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises ApiError with the error message' do
        expect { client.query(query) }.to raise_error(Printavo::ApiError, /Field not found/)
      end
    end
  end

  describe '#mutate' do
    let(:mutation) do
      <<~GQL
        mutation UpdateOrder($id: ID!, $nickname: String!) {
          updateOrder(id: $id, input: { nickname: $nickname }) {
            order { id nickname }
            errors
          }
        }
      GQL
    end
    let(:data) { { 'updateOrder' => { 'order' => { 'id' => '99', 'nickname' => 'Rush Job' }, 'errors' => [] } } }

    before { stub_success(data) }

    it 'returns the mutation data hash' do
      result = client.mutate(mutation, variables: { id: '99', nickname: 'Rush Job' })
      expect(result).to eq(data)
    end

    it 'sends a POST request to the GraphQL endpoint' do
      client.mutate(mutation, variables: { id: '99', nickname: 'Rush Job' })
      expect(WebMock).to have_requested(:post, endpoint)
    end

    context 'when the mutation returns GraphQL errors' do
      before do
        stub_request(:post, endpoint)
          .to_return(status: 200,
                     body: { 'errors' => [{ 'message' => 'Record not found' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises ApiError' do
        expect { client.mutate(mutation) }.to raise_error(Printavo::ApiError, /Record not found/)
      end
    end

    context 'when the API returns 401' do
      before { stub_request(:post, endpoint).to_return(status: 401, body: '') }

      it 'raises AuthenticationError' do
        expect { client.mutate(mutation) }.to raise_error(Printavo::AuthenticationError)
      end
    end
  end

  describe 'caching' do
    let(:data)   { { 'customers' => { 'nodes' => [{ 'id' => '1' }] } } }
    let(:cache)  { Printavo::MemoryStore.new }
    let(:cached_client) { described_class.new(connection, cache: cache, default_ttl: 300) }

    before { stub_success(data) }

    describe '#query' do
      it 'returns the same data on a cache hit' do
        first  = cached_client.query(query)
        second = cached_client.query(query)
        expect(second).to eq(first)
      end

      it 'only makes one HTTP request for identical queries' do
        cached_client.query(query)
        cached_client.query(query)
        expect(WebMock).to have_requested(:post, endpoint).once
      end

      it 'makes separate HTTP requests for different queries' do
        other_query = '{ orders { nodes { id } } }'
        stub_request(:post, endpoint)
          .to_return(status: 200, body: { 'data' => { 'orders' => { 'nodes' => [] } } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })
        cached_client.query(query)
        cached_client.query(other_query)
        expect(WebMock).to have_requested(:post, endpoint).twice
      end

      it 'makes separate HTTP requests when variables differ' do
        stub_request(:post, endpoint)
          .to_return(status: 200, body: { 'data' => data }.to_json,
                     headers: { 'Content-Type' => 'application/json' })
        cached_client.query(query, variables: { id: '1' })
        cached_client.query(query, variables: { id: '2' })
        expect(WebMock).to have_requested(:post, endpoint).twice
      end
    end

    describe '#mutate' do
      let(:mutation) { 'mutation { updateOrder(id: "1") { order { id } } }' }
      let(:mut_data) { { 'updateOrder' => { 'order' => { 'id' => '1' } } } }

      before do
        stub_request(:post, endpoint)
          .to_return(status: 200, body: { 'data' => mut_data }.to_json,
                     headers: { 'Content-Type' => 'application/json' })
      end

      it 'always makes an HTTP request regardless of cache' do
        cached_client.mutate(mutation)
        cached_client.mutate(mutation)
        expect(WebMock).to have_requested(:post, endpoint).twice
      end
    end
  end

  describe '#paginate' do
    let(:paginate_query) do
      <<~GQL
        query($first: Int, $after: String) {
          orders(first: $first, after: $after) {
            nodes { id nickname }
            pageInfo { hasNextPage endCursor }
          }
        }
      GQL
    end

    let(:page_one_data) do
      {
        'orders' => {
          'nodes' => [{ 'id' => '1', 'nickname' => 'Alpha' }, { 'id' => '2', 'nickname' => 'Beta' }],
          'pageInfo' => { 'hasNextPage' => true, 'endCursor' => 'cursor_1' }
        }
      }
    end
    let(:page_two_data) do
      {
        'orders' => {
          'nodes' => [{ 'id' => '3', 'nickname' => 'Gamma' }],
          'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
        }
      }
    end

    before do
      stub_request(:post, endpoint)
        .with(body: hash_including('variables' => hash_including('after' => nil)))
        .to_return(status: 200, body: { 'data' => page_one_data }.to_json,
                   headers: { 'Content-Type' => 'application/json' })
      stub_request(:post, endpoint)
        .with(body: hash_including('variables' => hash_including('after' => 'cursor_1')))
        .to_return(status: 200, body: { 'data' => page_two_data }.to_json,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'yields each page of nodes' do
      pages = []
      client.paginate(paginate_query, path: 'orders') { |nodes| pages << nodes }
      expect(pages.size).to eq(2)
    end

    it 'yields all nodes across pages in order' do
      all_nodes = []
      client.paginate(paginate_query, path: 'orders') { |nodes| all_nodes.concat(nodes) }
      expect(all_nodes.map { |n| n['nickname'] }).to eq(%w[Alpha Beta Gamma])
    end

    it 'stops after the last page' do
      call_count = 0
      client.paginate(paginate_query, path: 'orders') { call_count += 1 }
      expect(call_count).to eq(2)
    end

    context 'with a nested path' do
      let(:nested_query) do
        <<~GQL
          query($orderId: ID!, $first: Int, $after: String) {
            order(id: $orderId) {
              lineItems(first: $first, after: $after) {
                nodes { id name }
                pageInfo { hasNextPage endCursor }
              }
            }
          }
        GQL
      end
      let(:nested_data) do
        {
          'order' => {
            'lineItems' => {
              'nodes' => [{ 'id' => '7', 'name' => 'Front Print' }],
              'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
            }
          }
        }
      end

      before do
        stub_request(:post, endpoint)
          .to_return(status: 200, body: { 'data' => nested_data }.to_json,
                     headers: { 'Content-Type' => 'application/json' })
      end

      it 'resolves dot-separated paths' do
        nodes = []
        client.paginate(nested_query, path: 'order.lineItems',
                                      variables: { orderId: '99' }) { |n| nodes.concat(n) }
        expect(nodes.first['name']).to eq('Front Print')
      end
    end
  end
end
