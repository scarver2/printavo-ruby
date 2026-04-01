# lib/printavo/cli.rb
# frozen_string_literal: true

require 'thor'
require 'printavo'

module Printavo
  # Shared credential helper included by CLI and its subcommands.
  module CLIHelpers
    private

    # Builds a Printavo::Client from PRINTAVO_EMAIL / PRINTAVO_TOKEN env vars.
    # Raises Thor::Error with a human-readable message if either is missing.
    def build_client
      email = ENV.fetch('PRINTAVO_EMAIL', nil)
      token = ENV.fetch('PRINTAVO_TOKEN', nil)
      raise Thor::Error, 'PRINTAVO_EMAIL environment variable is required' unless email && !email.empty?
      raise Thor::Error, 'PRINTAVO_TOKEN environment variable is required' unless token && !token.empty?

      Printavo::Client.new(email: email, token: token)
    end
  end

  class CLI < Thor
    include CLIHelpers

    package_name 'printavo'

    def self.exit_on_failure? = true

    # ---------------------------------------------------------------------------
    # version
    # ---------------------------------------------------------------------------

    desc 'version', 'Print the printavo-ruby gem version'
    def version
      say Printavo::VERSION
    end

    # ---------------------------------------------------------------------------
    # customers
    # ---------------------------------------------------------------------------

    desc 'customers', 'List customers'
    method_option :first, type: :numeric, default: 25, desc: 'Number of records to return'
    def customers
      build_client.customers.all(first: options[:first]).each do |c|
        say "#{c.id.to_s.ljust(10)}  #{c.full_name.to_s.ljust(30)}  #{c.email}"
      end
    end

    # ---------------------------------------------------------------------------
    # orders subcommand
    # ---------------------------------------------------------------------------

    class Orders < Thor
      include CLIHelpers

      default_task :list

      desc 'list', 'List orders (default)'
      method_option :first, type: :numeric, default: 25, desc: 'Number of records to return'
      def list
        build_client.orders.all(first: options[:first]).each do |o|
          say "#{o.id.to_s.ljust(10)}  #{o.nickname.to_s.ljust(30)}  #{o.total_price}"
        end
      end

      desc 'find ID', 'Find an order by ID'
      def find(id)
        o = build_client.orders.find(id)
        say "id:          #{o.id}"
        say "nickname:    #{o.nickname}"
        say "total_price: #{o.total_price}"
        say "status:      #{o.status}"
      end
    end

    desc 'orders SUBCOMMAND ...ARGS', 'List orders or find a specific order'
    subcommand 'orders', Orders
  end
end
