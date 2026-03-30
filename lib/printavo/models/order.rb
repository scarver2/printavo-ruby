# lib/printavo/models/order.rb
# frozen_string_literal: true

module Printavo
  class Order < Models::Base
    def id          = self['id']
    def nickname    = self['nickname']
    def total_price = self['totalPrice']

    def status
      dig('status', 'name')
    end

    def status_id
      dig('status', 'id')
    end

    def status_color
      dig('status', 'color')
    end

    def status_key
      return nil if status.nil?

      status.downcase.gsub(/\s+/, '_').to_sym
    end

    def status?(key)
      status_key == key.to_sym
    end

    def customer
      attrs = self['customer']
      Customer.new(attrs) if attrs
    end
  end
end
