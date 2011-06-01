# require 'httparty'
require 'hashie'
require 'active_support/concern'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'
require "rest_client"
require 'json'

directory = File.expand_path(File.dirname(__FILE__))

Hash.send :include, Hashie::HashExtensions


module CloudFactory  

  class << self
    attr_accessor :api_key, :api_url, :api_version, :email
    def configure
      yield self
    end    
  end

  # Configuring the defaults
  # Set ENV['TEST'] is true for testing against the api
  # TEST=true bundle exec rspec spec/.....
  if ENV['TEST']
    API_CONFIG = YAML.load_file(File.expand_path("../../fixtures/api_credentials.yml", __FILE__))
    CloudFactory.configure do |config|
      config.api_version = API_CONFIG['api_version']
      config.api_url = API_CONFIG['api_url']
      config.api_key = API_CONFIG['api_key']
      config.email = API_CONFIG['email']
    end
  end
  
  class CloudFactoryError < StandardError
    attr_reader :data
  
    def initialize(data)
      @data = data
      super
    end
  end

  class ClientError < StandardError; end
  class ServerError < CloudFactoryError; end
  class General     < CloudFactoryError; end

  class Unauthorized < ClientError; end
  class NotFound     < ClientError; end
  
  class Unavailable  < StandardError; end
end

require 'cloud_factory/client'
require 'cloud_factory/line'
require 'cloud_factory/input_header'
require 'cloud_factory/worker'
require 'cloud_factory/human_worker'
require 'cloud_factory/google_translate_robot'
require 'cloud_factory/media_converter_robot'
require 'cloud_factory/station'
require 'cloud_factory/standard_instruction'
require 'cloud_factory/form_field'
require 'cloud_factory/custom_instruction'
require 'cloud_factory/run'
require 'cloud_factory/category'
