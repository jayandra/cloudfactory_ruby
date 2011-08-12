# CloudFactory Initializer
require 'cf'
CF.configure do |config|
  config.api_key = "your-api-key"
  config.account_name = "your-account-name"
  config.api_version = "v1"
  config.api_url = "http://cloudfactory.com/api/"
end