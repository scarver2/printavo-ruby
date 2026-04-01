# spec/printavo/resources/email_templates_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::EmailTemplates do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:template_data) { fake_email_template_attrs }
    let(:response_data) do
      { 'emailTemplates' => {
        'nodes' => [template_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::EmailTemplate)) }
    it { expect(resource.all.first.name).to eq(template_data['name']) }
  end

  describe '#find' do
    let(:template_data) { fake_email_template_attrs('id' => '30') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '30' })
        .and_return('emailTemplate' => template_data)
    end

    it { expect(resource.find('30')).to be_a(Printavo::EmailTemplate) }
    it { expect(resource.find('30').id).to eq('30') }
  end
end
