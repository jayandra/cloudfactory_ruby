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

module Cf
  class CLI < Thor
    include Thor::Actions
    include Cf::Config
    
    desc "target", "Setup the cloudfactory credentials"
    method_option :url, :type => :string, :desc => "sets the target url e.g. http://cloudfactory.com or http://sandbox.cloudfactory.com"
    def target
      target_url = options[:url] if options[:url]
      if target_url
        save_config(target_url)
        say("\nYour cloudfactory target url is saved as #{target_url}", :green)
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