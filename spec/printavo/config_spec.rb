# spec/printavo/config_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Config do
  subject(:config) { described_class.new }

  describe '#initialize' do
    it 'sets base_url to the Printavo v2 endpoint' do
      expect(config.base_url).to eq('https://www.printavo.com/api/v2')
    end

    it 'sets a default timeout of 30 seconds' do
      expect(config.timeout).to eq(30)
    end
  end

  describe 'BASE_URL' do
    it 'points to the v2 GraphQL endpoint' do
      expect(described_class::BASE_URL).to eq('https://www.printavo.com/api/v2')
    end
  end

  describe 'attribute accessors' do
    it 'allows email to be set and read' do
      config.email = 'test@example.com'
      expect(config.email).to eq('test@example.com')
    end

    it 'allows token to be set and read' do
      config.token = 'abc123'
      expect(config.token).to eq('abc123')
    end

    it 'allows base_url to be overridden' do
      config.base_url = 'https://staging.printavo.com/api/v2'
      expect(config.base_url).to eq('https://staging.printavo.com/api/v2')
    end

    it 'allows timeout to be overridden' do
      config.timeout = 60
      expect(config.timeout).to eq(60)
    end
  end
end
