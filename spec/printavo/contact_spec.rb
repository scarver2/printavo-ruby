# spec/printavo/contact_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Contact do
  subject(:contact) { described_class.new(fake_contact_attrs) }

  it { expect(contact.id).to be_a(String) }
  it { expect(contact.first_name).to be_a(String) }
  it { expect(contact.last_name).to be_a(String) }
  it { expect(contact.email).to include('@') }
  it { expect(contact.phone).to be_a(String) }
  it { expect(contact.created_at).to be_a(String) }
  it { expect(contact.updated_at).to be_a(String) }

  describe '#full_name' do
    it 'returns fullName from API when present' do
      c = described_class.new(fake_contact_attrs('fullName' => 'Jane Smith'))
      expect(c.full_name).to eq('Jane Smith')
    end

    it 'falls back to joining firstName and lastName' do
      c = described_class.new(fake_contact_attrs('fullName' => nil,
                                                 'firstName' => 'Jane',
                                                 'lastName' => 'Smith'))
      expect(c.full_name).to eq('Jane Smith')
    end
  end

  describe '#fax' do
    it 'returns nil when not set' do
      expect(contact.fax).to be_nil
    end

    it 'returns value when present' do
      c = described_class.new(fake_contact_attrs('fax' => '555-123-4567'))
      expect(c.fax).to eq('555-123-4567')
    end
  end
end
