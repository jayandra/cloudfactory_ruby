require 'cloud_factory'
require 'vcr'
require 'webmock'

RSpec.configure do |config|
  # config.before(:each) do
  #   CloudFactory.api_key = '9d51f463f0eb3e24ea72e7059a9a6a7604aa8717'
  #   CloudFactory.api_url = "sprout.lvh.me:3000/api/"
  # end
  config.filter_run :focus => true
  config.filter_run_excluding :broken => true
  config.run_all_when_everything_filtered = true
  config.extend VCR::RSpec::Macros
  # Tenant.current = Tenant.create(:host => SANDBOX)
end

# WebMock.disable_net_connect!(:allow => "sprout.lvh.me")


VCR.config do |c|
  c.cassette_library_dir     = 'fixtures/cassette_library'
  c.stub_with                :webmock
  c.ignore_localhost         = true
  c.default_cassette_options = { :record => :none }
end