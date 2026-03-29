# lib/printavo/models/job.rb
module Printavo
  class Job < Models::Base
    def id       = self['id']
    def name     = self['name']
    def quantity = self['quantity']
    def price    = self['price']
    def taxable  = self['taxable']

    def taxable?
      taxable == true
    end
  end
end
