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
    it { expect(described_class::DECLINED).to   eq('declined') }
    it { expect(described_class::PENDING).to    eq('pending') }
    it { expect(described_class::REVOKED).to    eq('revoked') }
    it { expect(described_class::UNAPPROVED).to eq('unapproved') }
  end

  describe Printavo::Enums::ContactSortField do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CONTACT_EMAIL).to eq('CONTACT_EMAIL') }
    it { expect(described_class::CONTACT_NAME).to  eq('CONTACT_NAME') }
    it { expect(described_class::CUSTOMER_NAME).to eq('CUSTOMER_NAME') }
    it { expect(described_class::ORDER_COUNT).to   eq('ORDER_COUNT') }
  end

  describe Printavo::Enums::LineItemSize do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::XS).to         eq('size_xs') }
    it { expect(described_class::S).to          eq('size_s') }
    it { expect(described_class::M).to          eq('size_m') }
    it { expect(described_class::L).to          eq('size_l') }
    it { expect(described_class::XL).to         eq('size_xl') }
    it { expect(described_class::TWO_XL).to     eq('size_2xl') }
    it { expect(described_class::THREE_XL).to   eq('size_3xl') }
    it { expect(described_class::FOUR_XL).to    eq('size_4xl') }
    it { expect(described_class::FIVE_XL).to    eq('size_5xl') }
    it { expect(described_class::SIX_XL).to     eq('size_6xl') }
    it { expect(described_class::YOUTH_XS).to   eq('size_yxs') }
    it { expect(described_class::YOUTH_S).to    eq('size_ys') }
    it { expect(described_class::YOUTH_M).to    eq('size_ym') }
    it { expect(described_class::YOUTH_L).to    eq('size_yl') }
    it { expect(described_class::YOUTH_XL).to   eq('size_yxl') }
    it { expect(described_class::TODDLER_2T).to eq('size_2t') }
    it { expect(described_class::TODDLER_3T).to eq('size_3t') }
    it { expect(described_class::TODDLER_4T).to eq('size_4t') }
    it { expect(described_class::TODDLER_5T).to eq('size_5t') }
    it { expect(described_class::INFANT_6M).to  eq('size_6m') }
    it { expect(described_class::INFANT_12M).to eq('size_12m') }
    it { expect(described_class::INFANT_18M).to eq('size_18m') }
    it { expect(described_class::INFANT_24M).to eq('size_24m') }
    it { expect(described_class::OTHER).to      eq('size_other') }
  end

  describe Printavo::Enums::LineItemStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::ARRIVED).to            eq('arrived') }
    it { expect(described_class::ATTACHED_TO_PO).to     eq('attached_to_po') }
    it { expect(described_class::IN).to                 eq('in') }
    it { expect(described_class::NEED_ORDERING).to      eq('need_ordering') }
    it { expect(described_class::ORDERED).to            eq('ordered') }
    it { expect(described_class::PARTIALLY_RECEIVED).to eq('partially_received') }
    it { expect(described_class::RECEIVED).to           eq('received') }
  end

  describe Printavo::Enums::MerchOrderDeliveryMethod do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::DELIVERY).to eq('DELIVERY') }
    it { expect(described_class::PICKUP).to   eq('PICKUP') }
  end

  describe Printavo::Enums::MerchOrderStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::FULFILLED).to   eq('FULFILLED') }
    it { expect(described_class::UNFULFILLED).to eq('UNFULFILLED') }
  end

  describe Printavo::Enums::MerchStoreStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CLOSED).to eq('CLOSED') }
    it { expect(described_class::LIVE).to   eq('LIVE') }
  end

  describe Printavo::Enums::MessageDeliveryStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::BOUNCED).to   eq('BOUNCED') }
    it { expect(described_class::CLICKED).to   eq('CLICKED') }
    it { expect(described_class::DELIVERED).to eq('DELIVERED') }
    it { expect(described_class::ERROR).to     eq('ERROR') }
    it { expect(described_class::LINKED).to    eq('LINKED') }
    it { expect(described_class::OPENED).to    eq('OPENED') }
    it { expect(described_class::OTHER).to     eq('OTHER') }
    it { expect(described_class::PAY_FOR).to   eq('PAY_FOR') }
    it { expect(described_class::PENDING).to   eq('PENDING') }
    it { expect(described_class::REJECTED).to  eq('REJECTED') }
    it { expect(described_class::SENT).to      eq('SENT') }
  end

  describe Printavo::Enums::OrderPaymentStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::PAID).to            eq('PAID') }
    it { expect(described_class::PARTIAL_PAYMENT).to eq('PARTIAL_PAYMENT') }
    it { expect(described_class::UNPAID).to          eq('UNPAID') }
  end

  describe Printavo::Enums::OrderSortField do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CUSTOMER_DUE_AT).to eq('CUSTOMER_DUE_AT') }
    it { expect(described_class::CUSTOMER_NAME).to   eq('CUSTOMER_NAME') }
    it { expect(described_class::OWNER).to           eq('OWNER') }
    it { expect(described_class::STATUS).to          eq('STATUS') }
    it { expect(described_class::TOTAL).to           eq('TOTAL') }
    it { expect(described_class::VISUAL_ID).to       eq('VISUAL_ID') }
  end

  describe Printavo::Enums::PaymentDisputeStatusField do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::DISPUTE_INITIATED).to eq('DISPUTE_INITIATED') }
    it { expect(described_class::DISPUTE_IN_REVIEW).to eq('DISPUTE_IN_REVIEW') }
    it { expect(described_class::DISPUTE_LOST).to      eq('DISPUTE_LOST') }
    it { expect(described_class::DISPUTE_WON).to       eq('DISPUTE_WON') }
    it { expect(described_class::RETRIEVAL_REQUEST).to eq('RETRIEVAL_REQUEST') }
  end

  describe Printavo::Enums::PaymentRequestStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::ARCHIVED).to eq('ARCHIVED') }
    it { expect(described_class::CLOSED).to   eq('CLOSED') }
    it { expect(described_class::OPEN).to     eq('OPEN') }
  end

  describe Printavo::Enums::PoGoodsStatus do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::ARRIVED).to            eq('arrived') }
    it { expect(described_class::NOT_ORDERED).to        eq('not_ordered') }
    it { expect(described_class::ORDERED).to            eq('ordered') }
    it { expect(described_class::PARTIALLY_RECEIVED).to eq('partially_received') }
    it { expect(described_class::RECEIVED).to           eq('received') }
  end

  describe Printavo::Enums::StatusType do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::INVOICE).to eq('INVOICE') }
    it { expect(described_class::QUOTE).to   eq('QUOTE') }
  end

  describe Printavo::Enums::TaskSortField do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CREATED_AT).to eq('CREATED_AT') }
    it { expect(described_class::DUE_AT).to     eq('DUE_AT') }
  end

  describe Printavo::Enums::TaskableType do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::CUSTOMER).to eq('CUSTOMER') }
    it { expect(described_class::INVOICE).to  eq('INVOICE') }
    it { expect(described_class::QUOTE).to    eq('QUOTE') }
  end

  describe Printavo::Enums::TransactionCategory do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::BANK_TRANSFER).to eq('BANK_TRANSFER') }
    it { expect(described_class::CASH).to          eq('CASH') }
    it { expect(described_class::CHECK).to         eq('CHECK') }
    it { expect(described_class::CREDIT_CARD).to   eq('CREDIT_CARD') }
    it { expect(described_class::ECHECK).to        eq('ECHECK') }
    it { expect(described_class::OTHER).to         eq('OTHER') }
  end

  describe Printavo::Enums::TransactionSource do
    it_behaves_like 'a Printavo enum'

    it { expect(described_class::MANUAL).to    eq('MANUAL') }
    it { expect(described_class::PROCESSOR).to eq('PROCESSOR') }
  end
end
