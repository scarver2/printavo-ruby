# .simplecov
# frozen_string_literal: true

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.output_directory        = 'coverage'
  c.lcov_file_name          = 'lcov.info'
end

SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter.new([
                                                       SimpleCov::Formatter::HTMLFormatter,
                                                       SimpleCov::Formatter::LcovFormatter
                                                     ])
  add_filter '/spec/'
  minimum_coverage 90
end
