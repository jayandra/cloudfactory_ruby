# CloudFactory Initializer
require 'cf'
CF.configure do |config|
  config.api_version = "v1"
  config.api_key = "<%= api_key %>"
  config.api_url = "http://cloudfactory.com/api/"
end