require 'thor'
require 'yaml'
require 'fileutils'

require File.expand_path('../../cf', __FILE__) #=> requiring the gem
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

cli_directory = File.expand_path("../cf/cli", File.dirname(__FILE__))
require "#{cli_directory}/config"
require "#{cli_directory}/line"
require "#{cli_directory}/form"
require "#{cli_directory}/production"

if ENV['TEST_CLI']
  require 'ruby-debug'
  API_CONFIG = YAML.load_file(File.expand_path("../../../fixtures/api_credentials.yml", __FILE__))
  CF.configure do |config|
    config.api_version = API_CONFIG['api_version']
    config.api_url = API_CONFIG['api_url']
    config.api_key = API_CONFIG['api_key']
  end
end

module Cf
  class CLI < Thor
    include Thor::Actions
    include Cf::Config
    
    desc "login", "Setup the cloudfactory credentials"
    method_option :url, :type => :string, :required => true, :desc => "sets the target url e.g. http://cloudfactory.com or http://sandbox.cloudfactory.com"
    def target
      target_url = options[:url]
      # account_name = ask("Enter your account name:")
      save_config(target_url)
      say("Your cloudfactory target url is saved as #{target_url}", :green)
      say("All the best to run your factory on top of CloudFactory.com", :blue)
    end

    desc "line", "Commands to manage the Lines. For more info, cf line help"
    subcommand "line", Cf::Line

    desc "form", "Commands to generate custom task forms. For more info, cf form help"
    subcommand "form", Cf::Form
    
    desc "production", "Commands to create production runs. For more info, cf production help"
    # can use Run for the class name coz its a reserved word for Thor
    subcommand "production", Cf::Production
  end
end