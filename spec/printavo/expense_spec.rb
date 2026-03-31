# spec/printavo/expense_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Expense do
  subject(:expense) { described_class.new(fake_expense_attrs) }

  it { expect(expense.id).to be_a(String) }
  it { expect(expense.name).to be_a(String) }
  it { expect(expense.amount).to be_a(String) }
  it { expect(expense.category).to be_a(String) }
end
