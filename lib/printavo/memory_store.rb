# lib/printavo/memory_store.rb
# frozen_string_literal: true

module Printavo
  # A simple thread-safe in-memory cache store for use without Rails or Redis.
  # Implements the same +fetch+ / +delete+ interface as +Rails.cache+, so it
  # can be swapped for any compatible store without changing call sites.
  #
  # @example Standalone use
  #   client = Printavo::Client.new(
  #     email: ENV["PRINTAVO_EMAIL"],
  #     token: ENV["PRINTAVO_TOKEN"],
  #     cache: Printavo::MemoryStore.new
  #   )
  #
  # @example With custom default TTL
  #   client = Printavo::Client.new(
  #     email: ENV["PRINTAVO_EMAIL"],
  #     token: ENV["PRINTAVO_TOKEN"],
  #     cache:       Printavo::MemoryStore.new,
  #     default_ttl: 600  # 10 minutes
  #   )
  class MemoryStore
    def initialize
      @store      = {}
      @expires_at = {}
      @mutex      = Mutex.new
    end

    # Returns the cached value for +key+, or calls the block, stores the
    # result, and returns it. Expired entries are treated as missing.
    #
    # @param key        [String]
    # @param expires_in [Integer, nil] TTL in seconds; +nil+ means no expiry
    # @yieldreturn      the value to cache on a miss
    # @return           the cached or freshly-computed value
    def fetch(key, expires_in: nil)
      @mutex.synchronize do
        cached = read(key)
        return cached unless cached.nil?

        yield.tap { |v| write(key, v, expires_in: expires_in) }
      end
    end

    # Removes +key+ from the cache.
    #
    # @param key [String]
    # @return [nil]
    def delete(key)
      @mutex.synchronize do
        @store.delete(key)
        @expires_at.delete(key)
      end
      nil
    end

    private

    def read(key)
      exp = @expires_at[key]
      if @store.key?(key) && (exp.nil? || Time.now < exp)
        @store[key]
      else
        @store.delete(key)
        @expires_at.delete(key)
        nil
      end
    end

    def write(key, value, expires_in: nil)
      @store[key]      = value
      @expires_at[key] = Time.now + expires_in if expires_in
    end
  end
end
