# Guardfile
guard :rspec, cmd: 'bundle exec rspec --color --format progress' do
  watch('spec/spec_helper.rb')       { 'spec' }
  watch('lib/printavo.rb')           { 'spec' }
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/support/factories.rb') { 'spec' }
  watch('spec/support/vcr.rb')       { 'spec' }
end

guard :rubocop, all_on_start: false, cli: ['--format', 'clang'] do
  watch(/.+\.rb$/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end
