# spec/printavo/line_item_group_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::LineItemGroup do
  subject(:group) { described_class.new(fake_line_item_group_attrs) }

  it { expect(group.id).to be_a(String) }
  it { expect(group.name).to be_a(String) }
  it { expect(group.description).to be_a(String) }
end
