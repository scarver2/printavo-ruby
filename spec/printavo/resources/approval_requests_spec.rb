# spec/printavo/resources/approval_requests_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::ApprovalRequests do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:ar_data) { fake_approval_request_attrs }
    let(:response_data) do
      { 'order' => { 'approvalRequests' => {
        'nodes' => [ar_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(order_id: '99')).to all(be_a(Printavo::ApprovalRequest)) }
  end

  describe '#find' do
    let(:ar_data) { fake_approval_request_attrs('id' => '10') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '10' })
        .and_return('approvalRequest' => ar_data)
    end

    it { expect(resource.find('10')).to be_a(Printavo::ApprovalRequest) }
    it { expect(resource.find('10').id).to eq('10') }
  end

  describe '#create' do
    let(:ar_data) { fake_approval_request_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('approvalRequestCreate' => ar_data)
    end

    it { expect(resource.create(order_id: '99', contact_id: '1')).to be_a(Printavo::ApprovalRequest) }
  end

  describe '#approve' do
    let(:ar_data) { fake_approval_request_attrs('id' => '10', 'status' => Printavo::Enums::ApprovalRequestStatus::APPROVED) }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::APPROVE_MUTATION, variables: { id: '10' })
        .and_return('approvalRequestApprove' => ar_data)
    end

    it { expect(resource.approve('10')).to be_a(Printavo::ApprovalRequest) }
    it { expect(resource.approve('10').status).to eq(Printavo::Enums::ApprovalRequestStatus::APPROVED) }
  end

  describe '#revoke' do
    let(:ar_data) { fake_approval_request_attrs('id' => '10', 'status' => Printavo::Enums::ApprovalRequestStatus::REVOKED) }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::REVOKE_MUTATION, variables: { id: '10' })
        .and_return('approvalRequestRevoke' => ar_data)
    end

    it { expect(resource.revoke('10')).to be_a(Printavo::ApprovalRequest) }
    it { expect(resource.revoke('10').status).to eq(Printavo::Enums::ApprovalRequestStatus::REVOKED) }
  end

  describe '#unapprove' do
    let(:ar_data) { fake_approval_request_attrs('id' => '10', 'status' => Printavo::Enums::ApprovalRequestStatus::PENDING) }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UNAPPROVE_MUTATION, variables: { id: '10' })
        .and_return('approvalRequestUnapprove' => ar_data)
    end

    it { expect(resource.unapprove('10')).to be_a(Printavo::ApprovalRequest) }
    it { expect(resource.unapprove('10').status).to eq(Printavo::Enums::ApprovalRequestStatus::PENDING) }
  end
end
