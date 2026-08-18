# lib/printavo/response_envelope.rb
# frozen_string_literal: true

module Printavo
  class ResponseEnvelope
    attr_reader :data, :errors, :metadata, :response_payload

    def initialize(data:, errors: [], metadata: {}, response_payload: nil)
      @data = immutable_copy(data)
      @errors = immutable_copy(errors)
      @metadata = immutable_copy(metadata)
      @response_payload = immutable_payload(response_payload)
      freeze
    end

    def success?
      errors.empty?
    end

    def partial?
      !data.nil? && errors.any?
    end

    def to_h
      { 'data' => data, 'errors' => errors, 'metadata' => metadata }.freeze
    end

    def inspect
      "#<#{self.class} data=#{data.inspect} errors=#{errors.inspect} metadata=#{metadata.inspect}>"
    end

    private

    def immutable_payload(value)
      return if value.nil?
      raise ArgumentError, 'response_payload must be a String' unless value.is_a?(String)

      value.b.dup.freeze
    end

    def immutable_copy(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, item), copy|
          copy[key.to_s.freeze] = immutable_copy(item)
        end.freeze
      when Array
        value.map { |item| immutable_copy(item) }.freeze
      when String
        value.dup.freeze
      else
        value
      end
    end
  end
end
