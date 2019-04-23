# frozen_string_literal: true

require 'bundler/setup'
require 'pci_booking_api'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.define_derived_metadata do |metadata|
    metadata[:type] = :plain_ruby_class
  end
end
