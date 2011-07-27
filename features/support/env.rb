require 'ruby-debug'
require 'aruba/cucumber'
require 'cf'
ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

Before('@slow_process') do
  @aruba_io_wait_seconds = 4
  @aruba_timeout_seconds = 4
end

Before('@too_slow_process') do
  @aruba_io_wait_seconds = 4
  @aruba_timeout_seconds = 50
end

if ENV['TEST_CLI']
  API_CONFIG = YAML.load_file(File.expand_path("../../../fixtures/api_credentials.yml", __FILE__))
  CF.configure do |config|
    config.api_version = API_CONFIG['api_version']
    config.api_url = API_CONFIG['api_url']
    config.api_key = API_CONFIG['api_key']
  end
end