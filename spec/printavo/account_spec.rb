# spec/printavo/account_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Account do
  subject(:account) { described_class.new(fake_account_attrs) }

  it { expect(account.id).to be_a(String) }
  it { expect(account.company_name).to be_a(String) }
  it { expect(account.company_email).to include('@') }
  it { expect(account.phone).to be_a(String) }
  it { expect(account.website).to be_a(String) }
  it { expect(account.locale).to eq('en-US') }

  describe '#logo_url' do
    it 'returns nil when not set' do
      expect(account.logo_url).to be_nil
    end

    it 'returns value when present' do
      a = described_class.new(fake_account_attrs('logoUrl' => 'https://example.com/logo.png'))
      expect(a.logo_url).to eq('https://example.com/logo.png')
    end
  end
end
