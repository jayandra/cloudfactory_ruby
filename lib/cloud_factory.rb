require 'cloud_factory/line'
require 'cloud_factory/input_header'
require 'cloud_factory/worker'
require 'cloud_factory/human_worker'
require 'cloud_factory/robot_worker'
require 'cloud_factory/station'
require 'cloud_factory/standard_instruction'
require 'cloud_factory/form_field'
require 'cloud_factory/custom_instruction'
require 'cloud_factory/run'

module CloudFactory  
  
  class << self
    attr_accessor :api_key, :remote_uri
    
    def configure
      yield self
    end
  end
  
  # Configuring the defaults
  CloudFactory.remote_uri = "http://cloudfactory.com/api/v1/"
end