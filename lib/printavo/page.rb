# lib/printavo/page.rb
module Printavo
  # Wraps a single page of API results with cursor metadata.
  #
  # @example Iterating pages manually
  #   page = client.customers.fetch_page(first: 10)
  #   page.records.each { |c| puts c.full_name }
  #   puts page.has_next_page   # => true
  #   puts page.end_cursor      # => "cursor_abc123"
  #
  # @example Using each_page
  #   client.customers.each_page(first: 10) do |records|
  #     records.each { |c| puts c.full_name }
  #   end
  Page = Struct.new(:records, :has_next_page, :end_cursor, keyword_init: true) do
    def to_a    = records
    def size    = records.size
    def empty?  = records.empty?
  end
end
