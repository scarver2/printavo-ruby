#!/usr/bin/env ruby
# bin/verify-package.rb
# frozen_string_literal: true

require 'rubygems/package'

package_file = File.expand_path(ARGV.fetch(0))
root = File.expand_path('..', __dir__)
public_globs = %w[
  bin/printavo
  docs/**/*.md
  lib/**/*.graphql
  lib/**/*.rb
  LICENSE
  README.md
]
expected_files = Dir.glob(public_globs, base: root).select do |file|
  File.file?(File.join(root, file))
end.sort
packaged_files = Gem::Package.new(package_file).contents.sort

missing_files = expected_files - packaged_files
unexpected_files = packaged_files - expected_files

abort "Missing packaged files: #{missing_files.join(', ')}" unless missing_files.empty?
abort "Unexpected packaged files: #{unexpected_files.join(', ')}" unless unexpected_files.empty?
abort 'Missing packaged executable: bin/printavo' unless packaged_files.include?('bin/printavo')

puts "Verified #{packaged_files.length} packaged files"
