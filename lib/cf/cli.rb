begin
  require 'psych'
rescue LoadError
  # do nothing
end
require 'yaml'
require 'fileutils'
require 'thor'
require "highline/import"
require 'csv-hash'

require File.expand_path('../../cf', __FILE__) #=> requiring the gem
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

cli_directory = File.expand_path("../cf/cli", File.dirname(__FILE__))
require "#{cli_directory}/config"
require "#{cli_directory}/line"
require "#{cli_directory}/form"
require "#{cli_directory}/production"
require "#{cli_directory}/line_yaml_validator"

if ENV['TEST']
  require 'ruby-debug'
end

module Cf # :nodoc: all
  class CLI < Thor # :nodoc: all
    include Thor::Actions
    include Cf::Config
    
    desc "login", "Setup the cloudfactory credentials"
    def login
      email = ask("Enter your email:")
      passwd = ask_password("Enter the password: ")
      
      set_target_uri(false)
      resp = CF::Account.login(email, passwd)
      if resp.error.blank? and resp.api_key.present?
        File.open(config_file, 'w') {|f| f.write({ :target_url => CF.api_url, :api_version => CF.api_version, :api_key => resp.api_key }.to_yaml) }
        say("\nNow you're logged in.\nTo get started, run cf help\n", :green)
      else
        say("\n#{resp.error.message}\nTry again with valid one.\n", :red)
      end
    end
    
    no_tasks do
      def ask_password(message)
        ::HighLine.new.ask(message) do |q| 
          q.echo = false
        end
      end
    end
    
    # desc "target", "Setup the cloudfactory credentials. e.g. cf target staging #=> http://sandbox.staging.cloudfactory.com (options: staging/development/production)"
    # def target(target_url=nil)
    #   if target_url.present?
    #     target_set_url = save_config(target_url)
    #     say("\nYour cloudfactory target url is saved as #{target_set_url}", :green)
    #     say("Since the target is changed, do cf login to set the valid api key.\n", :green)
    #   else
    #     if load_config
    #       say("\n#{load_config[:target_url]}\n", :green)
    #     else
    #       say("\nYou have not set the target url yet.", :red)
    #       say("Set it with: cf target staging or see the help.\n", :red)
    #     end
    #   end
    # end

    desc "line", "Commands to manage the Lines. For more info, cf line help"
    subcommand "line", Cf::Line

    desc "form", "Commands to generate custom task forms. For more info, cf form help"
    subcommand "form", Cf::Form
    
    desc "production", "Commands to create production runs. For more info, cf production help"
    # cannot use Run for the class name coz its a reserved word for Thor
    # later it can be replaced with hacked millisami-thor version of the thor library with run-time dependency via Bundler
    subcommand "production", Cf::Production

    desc "output <run-title>", "Get the output of run. For more info, cf output help"
    method_option :station_index, :type => :numeric, :aliases => "-s", :desc => "the index of the station"
    def output(run_title=nil)
      if run_title.present?
        run_title = run_title.parameterize
        line_source = Dir.pwd
        yaml_source = "#{line_source}/line.yml"

        unless File.exist?(yaml_source)
          say "The line.yml file does not exist in this directory", :red
          return
        end
        
        set_target_uri(false)
        if set_api_key(yaml_source)
          CF.account_name = CF::Account.info.name if CF.account_name.blank?
          run = CF::Run.find(run_title)
          if run.errors.blank?
            say("Fetching output for run: #{run_title}", :green)
            
            if options[:station_index].present?
              # Output for specific station
              output = CF::Run.output(:title => run_title, :station => options[:station_index])
            else
              # Ouput for the whole production run
              output = CF::Run.final_output(run_title)
            end
            res_array = []
            output.each do |o|
              res_array << o.to_hash
            end
            csv_str = CSVHash(res_array,res_array.first.keys)
            
            FileUtils.mkdir("#{line_source}/output") unless Dir.exist?("#{line_source}/output")
            csv_file_name = "#{line_source}/output/#{run_title}-#{Time.now.strftime("%e %b %Y %H:%m-%S%p").parameterize}.csv"
            File.open(csv_file_name, 'w') {|f| f.write(csv_str) }
            say("Output saved at #{csv_file_name}\n", :yellow)
          else
            say("Error: #{run.errors.inspect}")
          end
          
        else
          say("\nAPI key missing in line.yml file\n")
        end
      else
        say("\nThe run title must be provided to get the output.", :red)
        say("\te.g. cf output my-run-title\n", :yellow)
      end
    end
    
  end
end