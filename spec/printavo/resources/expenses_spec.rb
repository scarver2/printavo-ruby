# spec/printavo/resources/expenses_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Expenses do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:expense_data) { fake_expense_attrs }
    let(:response_data) do
      { 'order' => { 'expenses' => {
        'nodes' => [expense_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(order_id: '99')).to all(be_a(Printavo::Expense)) }
  end

  describe '#find' do
    let(:expense_data) { fake_expense_attrs('id' => '40') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '40' })
        .and_return('expense' => expense_data)
    end

    it { expect(resource.find('40')).to be_a(Printavo::Expense) }
    it { expect(resource.find('40').id).to eq('40') }
  end

  describe '#create' do
    let(:expense_data) { fake_expense_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('expenseCreate' => expense_data)
    end

    it { expect(resource.create(name: 'Ink', amount: '12.50')).to be_a(Printavo::Expense) }
  end

  describe '#update' do
    let(:expense_data) { fake_expense_attrs('id' => '40') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('expenseUpdate' => expense_data)
    end

    it { expect(resource.update('40', amount: '15.00')).to be_a(Printavo::Expense) }
  end
end
