# CloudFactory Initializer

CF.configure do |config|
  config.api_version = "v1"
  config.api_url = "http://#{account}.lvh.me:3000/api/"
  config.api_key = "#{api_key}"
end