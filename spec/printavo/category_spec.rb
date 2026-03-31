# spec/printavo/category_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Category do
  subject(:category) { described_class.new(fake_category_attrs) }

  it { expect(category.id).to be_a(String) }
  it { expect(category.name).to be_a(String) }
end
