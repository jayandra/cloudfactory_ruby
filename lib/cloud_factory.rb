require 'httparty'
require 'hashie'
require 'active_support/concern'
require 'active_support/core_ext/string/inflections'
require "rest_client"

directory = File.expand_path(File.dirname(__FILE__))

Hash.send :include, Hashie::HashExtensions


module CloudFactory  

  class << self
    attr_accessor :api_key, :api_url, :api_version, :email

    # def configure
    #       yield self
    #     end
    #configure do |c|
    api_key = "5c99665131ad4044968de3ca0b984c8c0d45e9a2"
    email 	 = "manish.das@sprout-technology.com"
    api_url = "manishlaldas.lvh.me:3000/api/"
    api_version = "v1"
    #end
  end

  # Configuring the defaults
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

CloudFactory.configure do |config|
  config.api_version = "v1"
  config.api_url = "sprout.lvh.me:3000/api/"
  config.api_key = "133fcabc51e35903e616c25aace7ffccc819c8f0"
  config.email = "sachin@sproutify.com"
end

require 'cloud_factory/client'
require 'cloud_factory/client_request_response'
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
