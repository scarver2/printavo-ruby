# spec/printavo/resources/jobs_spec.rb
require 'spec_helper'

RSpec.describe Printavo::Resources::Jobs do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:job_data) { fake_job_attrs }
    let(:response_data) do
      {
        'order' => {
          'lineItems' => {
            'nodes' => [job_data],
            'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
          }
        }
      }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '55', first: 25, after: nil })
        .and_return(response_data)
    end

    it 'returns an array of Job models' do
      result = resource.all(order_id: '55')
      expect(result).to all(be_a(Printavo::Job))
    end

    it 'maps job attributes' do
      job = resource.all(order_id: '55').first
      expect(job.id).to       eq(job_data['id'])
      expect(job.name).to     eq(job_data['name'])
      expect(job.quantity).to eq(job_data['quantity'])
    end
  end

  describe '#find' do
    let(:job_data)      { fake_job_attrs('id' => '77', 'taxable' => true) }
    let(:response_data) { { 'lineItem' => job_data } }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '77' })
        .and_return(response_data)
    end

    it 'returns a single Job model' do
      job = resource.find('77')
      expect(job).to be_a(Printavo::Job)
      expect(job.id).to eq('77')
    end

    it 'exposes the taxable? predicate' do
      job = resource.find('77')
      expect(job.taxable?).to be true
    end
  end
end
