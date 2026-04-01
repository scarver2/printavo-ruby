# spec/printavo/email_template_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::EmailTemplate do
  subject(:email_template) { described_class.new(fake_email_template_attrs) }

  it { expect(email_template.id).to be_a(String) }
  it { expect(email_template.name).to be_a(String) }
  it { expect(email_template.subject).to be_a(String) }
  it { expect(email_template.body).to be_a(String) }
end
