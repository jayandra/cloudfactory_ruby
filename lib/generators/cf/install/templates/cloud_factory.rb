# CloudFactory Initializer

CF.configure do |config|
  config.api_version = "v1"
  config.api_url = "http://<%= account_name %>.cloudfactory.com/api/"
  config.api_key = "<%= api_key %>"
end