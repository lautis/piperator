require 'bundler/setup'

if RUBY_VERSION >= '2.5'
  require 'simplecov'
  require 'simplecov-cobertura'
  SimpleCov.start do
    add_filter '/spec/'
  end

  if ENV['CI']
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end
end

require 'piperator'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
