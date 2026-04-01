# spec/printavo/user_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::User do
  subject(:user) { described_class.new(fake_user_attrs) }

  it { expect(user.id).to be_a(String) }
  it { expect(user.first_name).to be_a(String) }
  it { expect(user.last_name).to be_a(String) }
  it { expect(user.email).to be_a(String) }

  describe '#full_name' do
    it 'joins first and last name' do
      u = described_class.new(fake_user_attrs('firstName' => 'Jane', 'lastName' => 'Smith'))
      expect(u.full_name).to eq('Jane Smith')
    end
  end
end
