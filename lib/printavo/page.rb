# lib/printavo/page.rb
# frozen_string_literal: true

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
  Page = Struct.new(
    :records,
    :has_next_page,
    :end_cursor,
    :errors,
    :metadata,
    :response_payload,
    keyword_init: true
  ) do
    def initialize(**attributes)
      payload = attributes[:response_payload]
      raise ArgumentError, 'response_payload must be a String' if payload && !payload.is_a?(String)

      payload = payload.b.dup.freeze if payload
      super(**attributes.merge(response_payload: payload))
    end

    def to_a    = records
    def size    = records.size
    def empty?  = records.empty?
    def success? = Array(errors).empty?
    def partial? = records.any? && !success?

    def inspect
      "#<#{self.class} records=#{records.inspect} has_next_page=#{has_next_page.inspect} " \
        "end_cursor=#{end_cursor.inspect} errors=#{errors.inspect} metadata=#{metadata.inspect}>"
    end
  end
end
