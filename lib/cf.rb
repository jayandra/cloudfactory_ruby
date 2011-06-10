require 'hashie'
require 'active_support/concern'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'
require "rest_client"
require 'json'

directory = File.expand_path(File.dirname(__FILE__))

Hash.send :include, Hashie::HashExtensions


module CF  

  class << self
    attr_accessor :api_key, :api_url, :api_version
    def configure
      yield self
    end    
  end

  # Configuring the defaults
  # Set ENV['TEST'] is true for testing against the api
  # TEST=true bundle exec rspec spec/.....
  if ENV['TEST']
    API_CONFIG = YAML.load_file(File.expand_path("../../fixtures/api_credentials.yml", __FILE__))
    CF.configure do |config|
      config.api_version = API_CONFIG['api_version']
      config.api_url = API_CONFIG['api_url']
      config.api_key = API_CONFIG['api_key']
    end
  end
  
  class CFError < StandardError
    attr_reader :data
  
    def initialize(data)
      @data = data
      super
    end
  end

  class ClientError < StandardError; end
  class ServerError < CFError; end
  class General     < CFError; end

  class Unauthorized < ClientError; end
  class NotFound     < ClientError; end
  
  class Unavailable  < StandardError; end
end

require 'cf/client'
require 'cf/line'
require 'cf/input_header'
require 'cf/worker'
require 'cf/human_worker'
require 'cf/google_translate_robot'
require 'cf/media_converter_robot'
require 'cf/station'
require 'cf/form'
require 'cf/form_field'
require 'cf/custom_form'
require 'cf/run'
require 'cf/department'
require 'cf/result'
