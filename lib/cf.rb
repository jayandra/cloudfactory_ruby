require 'rails'
require 'hashie'
require 'active_support/concern'
#require 'active_support/rescuable'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require "rest_client"
require 'json'

directory = File.expand_path(File.dirname(__FILE__))

Hash.send :include, Hashie::HashExtensions


module CF  

  class << self
    attr_accessor :api_key, :account_name, :api_version, :api_url
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
      config.account_name = API_CONFIG['account_name']
      config.api_version = API_CONFIG['api_version']
      config.api_url = API_CONFIG['api_url']
      config.api_key = API_CONFIG['api_key']
    end
  end
  
  # FIX: raise the exception along with the response error message
  # Ref: http://www.simonecarletti.com/blog/2009/12/inside-ruby-on-rails-rescuable-and-rescue_from/
  # class CFError < StandardError
  #   
  #   include ActiveSupport::Rescuable
  #   
  #   attr_reader :data
  #   rescue_from NotFound, :with => :render_error
  #   
  #   def initialize(data)
  #     @data = data
  #     # debugger
  #     super
  #   end
  #   
  #   def to_s
  #     "Error: #{@data}"
  #   end
  #   
  #   def render_error(exception)
  #     @error = exception
  #     "Error: #{exception.class}: #{exception.message}"
  #     debugger
  #     puts ""
  #   end
  #   
  # end
  # 
  # 
  # class ClientError < StandardError; end
  # class ServerError < CFError; end
  # class General     < CFError; end
  # 
  # class ImproveStationNotAllowed     < CFError; end
  # 
  # class Unauthorized < ClientError; end
  # class NotFound     < ClientError
  #   # attr_accessor :data
  #   # def initialize(data)
  #   #   
  #   #   @data = data
  #   #   debugger
  #   #   puts ""
  #   # end
  # end
  # 
  # class Unavailable  < StandardError; end
end

require "#{directory}/cf/client"
require "#{directory}/cf/account"
require "#{directory}/cf/line"
require "#{directory}/cf/input_format"
require "#{directory}/cf/worker"
require "#{directory}/cf/human_worker"
require "#{directory}/cf/google_translate_robot"
require "#{directory}/cf/media_converter_robot"
require "#{directory}/cf/station"
require "#{directory}/cf/task_form"
require "#{directory}/cf/form_field"
require "#{directory}/cf/custom_task_form"
require "#{directory}/cf/run"
require "#{directory}/cf/department"
require "#{directory}/cf/final_output"