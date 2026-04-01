# spec/printavo/cli_spec.rb
# frozen_string_literal: true

require 'spec_helper'
require 'printavo/cli'

RSpec.describe Printavo::CLI do
  let(:mock_client) { instance_double(Printavo::Client) }
  let(:cli)         { described_class.new([], { first: 25 }) }

  before do
    allow(cli).to receive(:build_client).and_return(mock_client)
    allow(cli).to receive(:say)
  end

  # ---------------------------------------------------------------------------
  # build_client (via CLIHelpers)
  # ---------------------------------------------------------------------------

  describe '#build_client' do
    subject(:bare_cli) { described_class.new }

    context 'when PRINTAVO_EMAIL is missing' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('PRINTAVO_EMAIL', nil).and_return(nil)
      end

      it 'raises Thor::Error' do
        expect { bare_cli.send(:build_client) }.to raise_error(Thor::Error, /PRINTAVO_EMAIL/)
      end
    end

    context 'when PRINTAVO_EMAIL is empty' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('PRINTAVO_EMAIL', nil).and_return('')
      end

      it 'raises Thor::Error' do
        expect { bare_cli.send(:build_client) }.to raise_error(Thor::Error, /PRINTAVO_EMAIL/)
      end
    end

    context 'when PRINTAVO_TOKEN is missing' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('PRINTAVO_EMAIL', nil).and_return('user@example.com')
        allow(ENV).to receive(:fetch).with('PRINTAVO_TOKEN', nil).and_return(nil)
      end

      it 'raises Thor::Error' do
        expect { bare_cli.send(:build_client) }.to raise_error(Thor::Error, /PRINTAVO_TOKEN/)
      end
    end

    context 'when PRINTAVO_TOKEN is empty' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('PRINTAVO_EMAIL', nil).and_return('user@example.com')
        allow(ENV).to receive(:fetch).with('PRINTAVO_TOKEN', nil).and_return('')
      end

      it 'raises Thor::Error' do
        expect { bare_cli.send(:build_client) }.to raise_error(Thor::Error, /PRINTAVO_TOKEN/)
      end
    end

    context 'when both credentials are present' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('PRINTAVO_EMAIL', nil).and_return('user@example.com')
        allow(ENV).to receive(:fetch).with('PRINTAVO_TOKEN', nil).and_return('tok')
        allow(Printavo::Client).to receive(:new).and_return(mock_client)
      end

      it 'returns a Printavo::Client' do
        expect(bare_cli.send(:build_client)).to eq(mock_client)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # version
  # ---------------------------------------------------------------------------

  describe '#version' do
    it 'prints the gem version' do
      allow(cli).to receive(:say)
      cli.version
      expect(cli).to have_received(:say).with(Printavo::VERSION)
    end
  end

  # ---------------------------------------------------------------------------
  # customers
  # ---------------------------------------------------------------------------

  describe '#customers' do
    let(:customers_resource) { instance_double(Printavo::Resources::Customers) }
    let(:fake_customer) do
      instance_double(Printavo::Customer, id: '1', full_name: 'Jane Smith', email: 'jane@example.com')
    end

    before do
      allow(mock_client).to receive(:customers).and_return(customers_resource)
      allow(customers_resource).to receive(:all).with(first: 25).and_return([fake_customer])
    end

    it 'fetches customers with the first option' do
      cli.customers
      expect(customers_resource).to have_received(:all).with(first: 25)
    end

    it 'outputs one line per customer' do
      cli.customers
      expect(cli).to have_received(:say).once
    end
  end

  # ---------------------------------------------------------------------------
  # orders subcommand
  # ---------------------------------------------------------------------------

  describe Printavo::CLI::Orders do
    let(:orders_cli) { described_class.new([], { first: 25 }) }

    before do
      allow(orders_cli).to receive(:build_client).and_return(mock_client)
      allow(orders_cli).to receive(:say)
    end

    describe '#list' do
      let(:orders_resource) { instance_double(Printavo::Resources::Orders) }
      let(:fake_order) do
        instance_double(Printavo::Order, id: '99', nickname: 'Rush Hoodies', total_price: '500.00')
      end

      before do
        allow(mock_client).to receive(:orders).and_return(orders_resource)
        allow(orders_resource).to receive(:all).with(first: 25).and_return([fake_order])
      end

      it 'fetches orders with the first option' do
        orders_cli.list
        expect(orders_resource).to have_received(:all).with(first: 25)
      end

      it 'outputs one line per order' do
        orders_cli.list
        expect(orders_cli).to have_received(:say).once
      end
    end

    describe '#find' do
      let(:orders_resource) { instance_double(Printavo::Resources::Orders) }
      let(:fake_order) do
        instance_double(Printavo::Order,
                        id: '99', nickname: 'Rush Hoodies',
                        total_price: '500.00', status: 'In Production')
      end

      before do
        allow(mock_client).to receive(:orders).and_return(orders_resource)
        allow(orders_resource).to receive(:find).with('99').and_return(fake_order)
      end

      it 'finds the order by ID' do
        orders_cli.find('99')
        expect(orders_resource).to have_received(:find).with('99')
      end

      it 'outputs four lines of order detail' do
        orders_cli.find('99')
        expect(orders_cli).to have_received(:say).exactly(4).times
      end
    end
  end
end
