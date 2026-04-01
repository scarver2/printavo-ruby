# spec/printavo/enums_spec.rb
# frozen_string_literal: true

require 'spec_helper'

# Shared behaviour: every enum module must have a frozen ALL array that
# contains exactly the values of its own public constants (minus ALL itself).
RSpec.shared_examples 'a Printavo enum' do
  it 'defines ALL as a frozen Array' do
    expect(described_class::ALL).to be_a(Array)
    expect(described_class::ALL).to be_frozen
  end

  it 'ALL contains every constant value' do
    expected = described_class.constants(false)
                              .reject { |c| c == :ALL }
                              .map { |c| described_class.const_get(c) }
                              .sort
    expect(described_class::ALL.sort).to eq(expected)
  end

  it 'every constant value is a frozen String' do
    expect(described_class::ALL).to all(be_a(String).and(be_frozen))
  end
end

RSpec.describe Printavo::Enums do
  describe Printavo::Enums::ApprovalRequestStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::APPROVED).to   eq('approved') }
    it { expect(described_class::PENDING).to    eq('pending') }
    it { expect(described_class::REVOKED).to    eq('revoked') }
    it { expect(described_class::UNAPPROVED).to eq('unapproved') }
  end

  describe Printavo::Enums::ContactSortField do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CREATED_AT).to eq('CREATED_AT') }
    it { expect(described_class::EMAIL).to      eq('EMAIL') }
    it { expect(described_class::FIRST_NAME).to eq('FIRST_NAME') }
    it { expect(described_class::LAST_NAME).to  eq('LAST_NAME') }
    it { expect(described_class::UPDATED_AT).to eq('UPDATED_AT') }
  end

  describe Printavo::Enums::LineItemSize do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::NONE).to     eq('NONE') }
    it { expect(described_class::OS).to       eq('OS') }
    it { expect(described_class::XS).to       eq('XS') }
    it { expect(described_class::S).to        eq('S') }
    it { expect(described_class::M).to        eq('M') }
    it { expect(described_class::L).to        eq('L') }
    it { expect(described_class::XL).to       eq('XL') }
    it { expect(described_class::TWO_XL).to   eq('2XL') }
    it { expect(described_class::THREE_XL).to eq('3XL') }
  end

  describe Printavo::Enums::LineItemStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::ACTIVE).to    eq('ACTIVE') }
    it { expect(described_class::CANCELLED).to eq('CANCELLED') }
  end

  describe Printavo::Enums::MerchOrderDeliveryMethod do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::LOCAL_DELIVERY).to eq('LOCAL_DELIVERY') }
    it { expect(described_class::PICKUP).to         eq('PICKUP') }
    it { expect(described_class::SHIP).to           eq('SHIP') }
  end

  describe Printavo::Enums::MerchOrderStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CANCELLED).to  eq('CANCELLED') }
    it { expect(described_class::COMPLETE).to   eq('COMPLETE') }
    it { expect(described_class::PENDING).to    eq('PENDING') }
    it { expect(described_class::PROCESSING).to eq('PROCESSING') }
  end

  describe Printavo::Enums::MerchStoreStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::ACTIVE).to   eq('ACTIVE') }
    it { expect(described_class::ARCHIVED).to eq('ARCHIVED') }
    it { expect(described_class::CLOSED).to   eq('CLOSED') }
  end

  describe Printavo::Enums::MessageDeliveryStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::BOUNCED).to   eq('BOUNCED') }
    it { expect(described_class::DELIVERED).to eq('DELIVERED') }
    it { expect(described_class::FAILED).to    eq('FAILED') }
    it { expect(described_class::PENDING).to   eq('PENDING') }
    it { expect(described_class::SENT).to      eq('SENT') }
  end

  describe Printavo::Enums::OrderPaymentStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::PAID).to    eq('PAID') }
    it { expect(described_class::PARTIAL).to eq('PARTIAL') }
    it { expect(described_class::UNPAID).to  eq('UNPAID') }
  end

  describe Printavo::Enums::OrderSortField do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CREATED_AT).to      eq('CREATED_AT') }
    it { expect(described_class::CUSTOMER_DUE_AT).to eq('CUSTOMER_DUE_AT') }
    it { expect(described_class::DUE_AT).to          eq('DUE_AT') }
    it { expect(described_class::UPDATED_AT).to      eq('UPDATED_AT') }
    it { expect(described_class::VISUAL_ID).to       eq('VISUAL_ID') }
  end

  describe Printavo::Enums::PaymentDisputeStatusField do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::LOST).to           eq('LOST') }
    it { expect(described_class::NEEDS_RESPONSE).to eq('NEEDS_RESPONSE') }
    it { expect(described_class::RESOLVED).to       eq('RESOLVED') }
    it { expect(described_class::UNDER_REVIEW).to   eq('UNDER_REVIEW') }
    it { expect(described_class::WON).to            eq('WON') }
  end

  describe Printavo::Enums::PaymentRequestStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CANCELLED).to eq('CANCELLED') }
    it { expect(described_class::PAID).to      eq('PAID') }
    it { expect(described_class::SENT).to      eq('SENT') }
  end

  describe Printavo::Enums::PoGoodsStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CANCELLED).to eq('CANCELLED') }
    it { expect(described_class::PARTIAL).to   eq('PARTIAL') }
    it { expect(described_class::PENDING).to   eq('PENDING') }
    it { expect(described_class::RECEIVED).to  eq('RECEIVED') }
  end

  describe Printavo::Enums::StatusType do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::INVOICE).to eq('INVOICE') }
    it { expect(described_class::QUOTE).to   eq('QUOTE') }
  end

  describe Printavo::Enums::TaskSortField do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::BODY).to       eq('BODY') }
    it { expect(described_class::CREATED_AT).to eq('CREATED_AT') }
    it { expect(described_class::DUE_AT).to     eq('DUE_AT') }
    it { expect(described_class::UPDATED_AT).to eq('UPDATED_AT') }
  end

  describe Printavo::Enums::TaskableType do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::INVOICE).to eq('INVOICE') }
    it { expect(described_class::QUOTE).to   eq('QUOTE') }
  end

  describe Printavo::Enums::TransactionCategory do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::PAYMENT).to eq('PAYMENT') }
    it { expect(described_class::REFUND).to  eq('REFUND') }
  end

  describe Printavo::Enums::TransactionSource do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CARD).to   eq('CARD') }
    it { expect(described_class::CASH).to   eq('CASH') }
    it { expect(described_class::CHECK).to  eq('CHECK') }
    it { expect(described_class::MANUAL).to eq('MANUAL') }
    it { expect(described_class::ONLINE).to eq('ONLINE') }
  end
end
