require 'thor'
require File.expand_path('../../cf', __FILE__) #=> requiring the gem
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

cli_directory = File.expand_path("../cf/cli", File.dirname(__FILE__))
require "#{cli_directory}/config"
require "#{cli_directory}/line"
require "#{cli_directory}/form"
require "#{cli_directory}/run"

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
    
    # desc "login", "Asks for the login information"
    # def login
    #   api_key = ask("Enter the api_key:")
    #   save_config(api_key)
    #   say("API Key saved at #{config_file}", :green)
    # end

    desc "line", "Commands to manage the Lines. For more info, cf line help"
    subcommand "line", Cf::Line

    desc "form", "Commands to generate custom task forms. For more info, cf form help"
    subcommand "form", Cf::Form
    
    desc "run", "Commands to create production run. For more info, cf run help"
    # can use Run for the class name coz its a reserved word for Thor
    subcommand "run", Cf::Run
  end
end