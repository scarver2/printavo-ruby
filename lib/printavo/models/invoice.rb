# lib/printavo/models/invoice.rb
# frozen_string_literal: true

module Printavo
  class Invoice < Models::Base
    def id                 = self['id']
    def visual_id          = self['visualId']
    def nickname           = self['nickname']
    def created_at         = self['createdAt']
    def updated_at         = self['updatedAt']
    def total              = self['total']
    def amount_paid        = self['amountPaid']
    def amount_outstanding = self['amountOutstanding']
    def paid_in_full?      = self['paidInFull']
    def invoice_at         = self['invoiceAt']
    def payment_due_at     = self['paymentDueAt']

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

    def contact
      attrs = self['contact']
      Contact.new(attrs) if attrs
    end
  end
end
