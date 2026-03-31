# spec/printavo/resources/payments_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Payments do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:payment_data) { fake_payment_attrs }
    let(:response_data) do
      { 'order' => { 'payments' => {
        'nodes' => [payment_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(order_id: '99')).to all(be_a(Printavo::Payment)) }
  end

  describe '#find' do
    let(:payment_data) { fake_payment_attrs('id' => '40') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '40' })
        .and_return('payment' => payment_data)
    end

    it { expect(resource.find('40')).to be_a(Printavo::Payment) }
    it { expect(resource.find('40').id).to eq('40') }
  end
end
