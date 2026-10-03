# spec/printavo/line_item_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::LineItem do
  subject(:line_item) { described_class.new(fake_line_item_attrs) }

  it { expect(line_item.id).to be_a(String) }
  it { expect(line_item.name).to be_a(String) }
  it { expect(line_item.quantity).to be_a(Integer) }
  it { expect(line_item.price).to be_a(String) }
  it { expect(line_item.taxable).to be false }
  it { expect(line_item.taxable?).to be false }

  describe '#taxable?' do
    it 'returns true when taxable is true' do
      expect(described_class.new(fake_line_item_attrs('taxable' => true)).taxable?).to be true
    end
  end

  describe 'documented line-item details' do
    subject(:line_item) do
      described_class.new(
        'category' => { 'id' => 'category-1', 'name' => 'Apparel' },
        'color' => 'Navy',
        'description' => 'Premium tee',
        'itemNumber' => 'TEE-1',
        'items' => 12,
        'markupPercentage' => 35.0,
        'merch' => true,
        'position' => 2,
        'personalizations' => [{ 'id' => 'personalization-1', 'name' => 'Name', 'personalization' => 'Taylor' }],
        'poLineItem' => {
          'id' => 'po-line-item-1',
          'category' => { 'id' => 'category-1', 'name' => 'Apparel' },
          'color' => 'Navy',
          'description' => 'Premium tee',
          'itemNumber' => 'TEE-1',
          'items' => 12,
          'position' => 2,
          'purchaseOrder' => {
            'id' => 'po-1',
            'goodsStatus' => 'ORDERED',
            'note' => 'Rush',
            'visualPoId' => 'PO-100',
            'vendor' => { 'id' => 'vendor-1', 'name' => 'Example Vendor' }
          },
          'sizes' => [{ 'size' => 'L', 'count' => 12 }]
        },
        'priceReceipt' => {
          'defaultMarkupPercentage' => 25.0,
          'description' => 'Price matrix',
          'price' => '18.00',
          'signature' => 'signed'
        },
        'product' => {
          'id' => 'product-1',
          'brand' => 'Example',
          'color' => 'Navy',
          'description' => 'Premium tee',
          'itemNumber' => 'TEE-1'
        },
        'productStatus' => 'ACTIVE',
        'sizes' => [{ 'size' => 'L', 'count' => 12 }],
        'taxed' => true
      )
    end

    it { expect(line_item.category).to be_a(Printavo::Category) }
    it { expect(line_item.color).to eq('Navy') }
    it { expect(line_item.description).to eq('Premium tee') }
    it { expect(line_item.item_number).to eq('TEE-1') }
    it { expect(line_item.items).to eq(12) }
    it { expect(line_item.markup_percentage).to eq(35.0) }
    it { expect(line_item).to be_merch }
    it { expect(line_item.position).to eq(2) }
    it { expect(line_item.personalizations).to all(be_a(Printavo::Personalization)) }
    it { expect(line_item.personalizations.first.name).to eq('Name') }
    it { expect(line_item.personalizations.first.personalization).to eq('Taylor') }
    it { expect(line_item.po_line_item).to be_a(Printavo::PoLineItem) }
    it { expect(line_item.po_line_item.category).to be_a(Printavo::Category) }
    it { expect(line_item.po_line_item.sizes).to all(be_a(Printavo::LineItemSizeCount)) }
    it { expect(line_item.po_line_item.purchase_order).to be_a(Printavo::PurchaseOrder) }
    it { expect(line_item.po_line_item.purchase_order.vendor).to be_a(Printavo::Vendor) }
    it { expect(line_item.price_receipt).to be_a(Printavo::LineItemPriceReceipt) }
    it { expect(line_item.price_receipt.signature).to eq('signed') }
    it { expect(line_item.product).to be_a(Printavo::Product) }
    it { expect(line_item.product.item_number).to eq('TEE-1') }
    it { expect(line_item.product_status).to eq('ACTIVE') }
    it { expect(line_item.sizes).to all(be_a(Printavo::LineItemSizeCount)) }
    it { expect(line_item).to be_taxed }
    it { expect(line_item).to be_taxable }
  end
end
