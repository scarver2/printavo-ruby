# spec/printavo/resources/payment_requests_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::PaymentRequests do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:request_data) { fake_payment_request_attrs }
    let(:response_data) do
      { 'order' => { 'paymentRequests' => {
        'nodes' => [request_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(order_id: '99')).to all(be_a(Printavo::PaymentRequest)) }
  end

  describe '#find' do
    let(:request_data) { fake_payment_request_attrs('id' => '50') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '50' })
        .and_return('paymentRequest' => request_data)
    end

    it { expect(resource.find('50')).to be_a(Printavo::PaymentRequest) }
    it { expect(resource.find('50').id).to eq('50') }
  end

  describe '#create' do
    let(:request_data) { fake_payment_request_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('paymentRequestCreate' => request_data)
    end

    it { expect(resource.create(amount: '250.00', order_id: '99')).to be_a(Printavo::PaymentRequest) }
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '50' })
        .and_return('paymentRequestDelete' => { 'id' => '50' })
    end

    it { expect(resource.delete('50')).to be_nil }
  end
end
