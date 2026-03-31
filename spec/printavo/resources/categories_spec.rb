# spec/printavo/resources/categories_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Categories do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:category_data) { fake_category_attrs }
    let(:response_data) do
      { 'categories' => {
        'nodes' => [category_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::Category)) }
    it { expect(resource.all.first.name).to eq(category_data['name']) }
  end

  describe '#find' do
    let(:category_data) { fake_category_attrs('id' => '90') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '90' })
        .and_return('category' => category_data)
    end

    it { expect(resource.find('90')).to be_a(Printavo::Category) }
    it { expect(resource.find('90').id).to eq('90') }
  end
end
