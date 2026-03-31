# spec/printavo/thread_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Thread do
  subject(:thread) { described_class.new(fake_thread_attrs) }

  it { expect(thread.id).to be_a(String) }
  it { expect(thread.subject).to be_a(String) }
  it { expect(thread.created_at).to be_a(String) }
  it { expect(thread.updated_at).to be_a(String) }
end
