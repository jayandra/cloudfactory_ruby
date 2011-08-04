begin
  require 'psych'
rescue LoadError
  # do nothing
end
require 'yaml'
require 'fileutils'
require 'thor'
require "highline/import"

require File.expand_path('../../cf', __FILE__) #=> requiring the gem
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

cli_directory = File.expand_path("../cf/cli", File.dirname(__FILE__))
require "#{cli_directory}/config"
require "#{cli_directory}/line"
require "#{cli_directory}/form"
require "#{cli_directory}/production"

module Cf
  class CLI < Thor
    include Thor::Actions
    include Cf::Config
    
    desc "login", "Setup the cloudfactory credentials"
    def login
      email = ask("Enter your email:")
      passwd = ask_password("Enter the password: ")
      resp = CF::Account.login(email, passwd)
      if resp.error.blank? and resp.api_key.present?
        File.open(config_file, 'w') {|f| f.write({ :target_url => "http://sandbox.staging.cloudfactory.com/api/", :api_version => "v1", :api_key => resp.api_key }.to_yaml) }
        say("\nNow you're logged in.\nTo get started, run cf help\n", :green)
      else
        say("\n#{resp.error.message}\nTry again with valid credentials.\n", :red)
      end
    end
    
    no_tasks do
      def ask_password(message)
        ::HighLine.new.ask(message) do |q| 
          q.echo = false
        end
      end
    end
    
    desc "target", "Setup the cloudfactory credentials. e.g. cf target staging #=> http://sandbox.staging.cloudfactory.com (options: staging/development/production)"
    def target(target_url=nil)
      if target_url.present?
        target_set_url = save_config(target_url)
        say("\nYour cloudfactory target url is saved as #{target_set_url}", :green)
        say("All the best to run your factory on top of CloudFactory.com\n", :green)
      else
        if load_config
          say("\n#{load_config[:target_url]}\n", :green)
        else
          say("\nYou have not set the target url yet.", :yellow)
          say("Set the target uri with: cf target --url=http://sandbox.staging.cloudfactory.com\n", :yellow)
        end
      end
    end

    desc "line", "Commands to manage the Lines. For more info, cf line help"
    subcommand "line", Cf::Line

    desc "form", "Commands to generate custom task forms. For more info, cf form help"
    subcommand "form", Cf::Form
    
    desc "production", "Commands to create production runs. For more info, cf production help"
    # cannot use Run for the class name coz its a reserved word for Thor
    # later it can be replaced with hacked millisami-thor version of the thor library with run-time dependency via Bundler
    subcommand "production", Cf::Production
  end
end