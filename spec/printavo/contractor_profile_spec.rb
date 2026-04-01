# spec/printavo/contractor_profile_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::ContractorProfile do
  subject(:contractor_profile) { described_class.new(fake_contractor_profile_attrs) }

  it { expect(contractor_profile.id).to be_a(String) }
  it { expect(contractor_profile.name).to be_a(String) }
  it { expect(contractor_profile.email).to be_a(String) }
end
