# spec/printavo/production_file_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::ProductionFile do
  subject(:production_file) { described_class.new(fake_production_file_attrs) }

  it { expect(production_file.id).to be_a(String) }
  it { expect(production_file.url).to be_a(String) }
  it { expect(production_file.filename).to be_a(String) }
  it { expect(production_file.created_at).to be_a(String) }
end
