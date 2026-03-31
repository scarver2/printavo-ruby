# spec/printavo/resources/payment_terms_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::PaymentTerms do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:term_data) { fake_payment_term_attrs }
    let(:response_data) do
      { 'paymentTerms' => {
        'nodes' => [term_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::PaymentTerm)) }
    it { expect(resource.all.first.name).to eq(term_data['name']) }
  end

  describe '#find' do
    let(:term_data) { fake_payment_term_attrs('id' => '60') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '60' })
        .and_return('paymentTerm' => term_data)
    end

    it { expect(resource.find('60')).to be_a(Printavo::PaymentTerm) }
    it { expect(resource.find('60').id).to eq('60') }
  end

  describe '#create' do
    let(:term_data) { fake_payment_term_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('paymentTermCreate' => term_data)
    end

    it { expect(resource.create(name: 'Net 30', net_days: 30)).to be_a(Printavo::PaymentTerm) }
  end

  describe '#update' do
    let(:term_data) { fake_payment_term_attrs('id' => '60') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('paymentTermUpdate' => term_data)
    end

    it { expect(resource.update('60', name: 'Net 45', net_days: 45)).to be_a(Printavo::PaymentTerm) }
  end

  describe '#archive' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::ARCHIVE_MUTATION, variables: { id: '60' })
        .and_return('paymentTermArchive' => { 'id' => '60' })
    end

    it { expect(resource.archive('60')).to be_nil }
  end
end
