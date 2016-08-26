require 'simplecov'
require 'simplecov-console'
require 'coveralls'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console,
  Coveralls::SimpleCov::Formatter,
]
SimpleCov.start do
  add_filter "/spec/"
end

ENV.delete 'RESTCLIENT_LOG'
require_relative '../lib/dealbot'
require 'webmock/rspec'
require 'climate_control'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.warnings = true
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
  config.order = :random
  Kernel.srand config.seed

  config.before do
    allow(Dealbot).to receive(:log)
    allow(Dealbot::Pipedrive::Client).to receive(:api_key).and_return('abc123')
    allow(Dealbot::Pipedrive).to receive(:cadence_storage_field_id).and_return('ghi789')
  end
end
