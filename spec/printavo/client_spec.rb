# spec/printavo/client_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Client do
  subject(:client) { described_class.new(email: PRINTAVO_TEST_EMAIL, token: PRINTAVO_TEST_TOKEN) }

  describe '#initialize' do
    it 'creates a client with email and token' do
      expect(client).to be_a(described_class)
    end

    it 'exposes a graphql interface' do
      expect(client.graphql).to be_a(Printavo::GraphqlClient)
    end

    it 'supports multiple independent instances' do
      client_a = described_class.new(email: 'a@example.com', token: 'token_a')
      client_b = described_class.new(email: 'b@example.com', token: 'token_b')
      expect(client_a).not_to equal(client_b)
    end
  end

  describe '#account' do
    it 'returns an Account resource' do
      expect(client.account).to be_a(Printavo::Resources::Account)
    end
  end

  describe '#approval_requests' do
    it 'returns an ApprovalRequests resource' do
      expect(client.approval_requests).to be_a(Printavo::Resources::ApprovalRequests)
    end
  end

  describe '#contacts' do
    it 'returns a Contacts resource' do
      expect(client.contacts).to be_a(Printavo::Resources::Contacts)
    end
  end

  describe '#custom_addresses' do
    it 'returns a CustomAddresses resource' do
      expect(client.custom_addresses).to be_a(Printavo::Resources::CustomAddresses)
    end
  end

  describe '#customers' do
    it 'returns a Customers resource' do
      expect(client.customers).to be_a(Printavo::Resources::Customers)
    end
  end

  describe '#invoices' do
    it 'returns an Invoices resource' do
      expect(client.invoices).to be_a(Printavo::Resources::Invoices)
    end
  end

  describe '#statuses' do
    it 'returns a Statuses resource' do
      expect(client.statuses).to be_a(Printavo::Resources::Statuses)
    end
  end

  describe '#orders' do
    it 'returns an Orders resource' do
      expect(client.orders).to be_a(Printavo::Resources::Orders)
    end
  end

  describe '#payment_requests' do
    it 'returns a PaymentRequests resource' do
      expect(client.payment_requests).to be_a(Printavo::Resources::PaymentRequests)
    end
  end

  describe '#payment_terms' do
    it 'returns a PaymentTerms resource' do
      expect(client.payment_terms).to be_a(Printavo::Resources::PaymentTerms)
    end
  end

  describe '#payments' do
    it 'returns a Payments resource' do
      expect(client.payments).to be_a(Printavo::Resources::Payments)
    end
  end

  describe '#jobs' do
    it 'returns a Jobs resource' do
      expect(client.jobs).to be_a(Printavo::Resources::Jobs)
    end
  end

  describe '#email_templates' do
    it 'returns an EmailTemplates resource' do
      expect(client.email_templates).to be_a(Printavo::Resources::EmailTemplates)
    end
  end

  describe '#expenses' do
    it 'returns an Expenses resource' do
      expect(client.expenses).to be_a(Printavo::Resources::Expenses)
    end
  end

  describe '#fees' do
    it 'returns a Fees resource' do
      expect(client.fees).to be_a(Printavo::Resources::Fees)
    end
  end

  describe '#imprints' do
    it 'returns an Imprints resource' do
      expect(client.imprints).to be_a(Printavo::Resources::Imprints)
    end
  end

  describe '#inquiries' do
    it 'returns an Inquiries resource' do
      expect(client.inquiries).to be_a(Printavo::Resources::Inquiries)
    end
  end

  describe '#line_item_groups' do
    it 'returns a LineItemGroups resource' do
      expect(client.line_item_groups).to be_a(Printavo::Resources::LineItemGroups)
    end
  end

  describe '#line_items' do
    it 'returns a LineItems resource' do
      expect(client.line_items).to be_a(Printavo::Resources::LineItems)
    end
  end

  describe '#tasks' do
    it 'returns a Tasks resource' do
      expect(client.tasks).to be_a(Printavo::Resources::Tasks)
    end
  end

  describe '#threads' do
    it 'returns a Threads resource' do
      expect(client.threads).to be_a(Printavo::Resources::Threads)
    end
  end

  describe '#transactions' do
    it 'returns a Transactions resource' do
      expect(client.transactions).to be_a(Printavo::Resources::Transactions)
    end
  end

  describe '#transaction_payments' do
    it 'returns a TransactionPayments resource' do
      expect(client.transaction_payments).to be_a(Printavo::Resources::TransactionPayments)
    end
  end

  describe '#categories' do
    it 'returns a Categories resource' do
      expect(client.categories).to be_a(Printavo::Resources::Categories)
    end
  end

  describe '#contractor_profiles' do
    it 'returns a ContractorProfiles resource' do
      expect(client.contractor_profiles).to be_a(Printavo::Resources::ContractorProfiles)
    end
  end

  describe '#delivery_methods' do
    it 'returns a DeliveryMethods resource' do
      expect(client.delivery_methods).to be_a(Printavo::Resources::DeliveryMethods)
    end
  end

  describe '#types_of_work' do
    it 'returns a TypesOfWork resource' do
      expect(client.types_of_work).to be_a(Printavo::Resources::TypesOfWork)
    end
  end

  describe '#users' do
    it 'returns a Users resource' do
      expect(client.users).to be_a(Printavo::Resources::Users)
    end
  end

  describe '#vendors' do
    it 'returns a Vendors resource' do
      expect(client.vendors).to be_a(Printavo::Resources::Vendors)
    end
  end

  describe '#merch_orders' do
    it 'returns a MerchOrders resource' do
      expect(client.merch_orders).to be_a(Printavo::Resources::MerchOrders)
    end
  end

  describe '#merch_stores' do
    it 'returns a MerchStores resource' do
      expect(client.merch_stores).to be_a(Printavo::Resources::MerchStores)
    end
  end

  describe '#mockups' do
    it 'returns a Mockups resource' do
      expect(client.mockups).to be_a(Printavo::Resources::Mockups)
    end
  end

  describe '#preset_task_groups' do
    it 'returns a PresetTaskGroups resource' do
      expect(client.preset_task_groups).to be_a(Printavo::Resources::PresetTaskGroups)
    end
  end

  describe '#preset_tasks' do
    it 'returns a PresetTasks resource' do
      expect(client.preset_tasks).to be_a(Printavo::Resources::PresetTasks)
    end
  end

  describe '#pricing_matrices' do
    it 'returns a PricingMatrices resource' do
      expect(client.pricing_matrices).to be_a(Printavo::Resources::PricingMatrices)
    end
  end

  describe '#production_files' do
    it 'returns a ProductionFiles resource' do
      expect(client.production_files).to be_a(Printavo::Resources::ProductionFiles)
    end
  end

  describe '#products' do
    it 'returns a Products resource' do
      expect(client.products).to be_a(Printavo::Resources::Products)
    end
  end

  describe '#login' do
    it 'raises NotImplementedError' do
      expect { client.login }.to raise_error(NotImplementedError, /email \+ token/)
    end
  end

  describe '#logout' do
    it 'raises NotImplementedError' do
      expect { client.logout }.to raise_error(NotImplementedError, /stateless/)
    end
  end
end
