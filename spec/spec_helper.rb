require 'cf'
require 'vcr'
require 'webmock'
require 'ruby-debug'

RSpec.configure do |config|
  config.before(:suite) do
    ::Debugger.start
    ::Debugger.settings[:autoeval] = true if ::Debugger.respond_to?(:settings)

    API_CONFIG = YAML.load_file(File.expand_path("../../fixtures/api_credentials.yml", __FILE__))
    CF.configure do |config|
      config.account_name = API_CONFIG['account_name']
      config.api_version = API_CONFIG['api_version']
      config.api_url = API_CONFIG['api_url']
      config.api_key = API_CONFIG['api_key']
    end
  end
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