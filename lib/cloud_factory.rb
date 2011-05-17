require 'httparty'
require 'hashie'
require 'active_support/concern'
require 'active_support/core_ext/string/inflections'

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
  CloudFactory.api_url = "cloudfactory.com/api/"
  CloudFactory.api_version = "v1"
  
  # Set ENV['TEST'] is true for testing against the api
  # TEST=true bundle exec rspec spec/.....
  if ENV['TEST']
    CloudFactory.api_key = '5c99665131ad4044968de3ca0b984c8c0d45e9a2'
    CloudFactory.email = 'manish.das@sprout-technology.com'
    CloudFactory.api_url = "manishlaldas.lvh.me:3000/api/"
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
require 'cloud_factory/client_request_response'
require 'cloud_factory/line'
require 'cloud_factory/input_header'
require 'cloud_factory/worker'
require 'cloud_factory/human_worker'
require 'cloud_factory/google_translator'
require 'cloud_factory/station'
require 'cloud_factory/standard_instruction'
require 'cloud_factory/form_field'
require 'cloud_factory/custom_instruction'
require 'cloud_factory/run'
require 'cloud_factory/category'


