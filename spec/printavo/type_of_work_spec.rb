# spec/printavo/type_of_work_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::TypeOfWork do
  subject(:type_of_work) { described_class.new(fake_type_of_work_attrs) }

  it { expect(type_of_work.id).to be_a(String) }
  it { expect(type_of_work.name).to be_a(String) }
end
