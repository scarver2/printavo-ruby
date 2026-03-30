# spec/printavo/resources/account_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Account do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#find' do
    let(:account_data) { fake_account_attrs }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY)
        .and_return('account' => account_data)
    end

    it 'returns an Account' do
      expect(resource.find).to be_a(Printavo::Account)
    end

    it 'maps company_name correctly' do
      expect(resource.find.company_name).to eq(account_data['companyName'])
    end

    it 'maps company_email correctly' do
      expect(resource.find.company_email).to eq(account_data['companyEmail'])
    end

    it 'maps locale correctly' do
      expect(resource.find.locale).to eq('en-US')
    end
  end
end
