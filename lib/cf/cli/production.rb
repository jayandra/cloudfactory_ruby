require 'thor/group'

module Cf
  class Production < Thor
    include Cf::Config

    desc "production start <run-title>", "creates a production run with input data file at input/<run-title>.csv"
    method_option :input_data, :type => :string, :aliases => "-i", :desc => "the name of the input data file"

    def start(title=nil)
      
      if title.nil?
        say("The run title is required to start the production.", :red) and return
      end
      
      run_title         = title.underscore.dasherize
      line_destination  = Dir.pwd
      line_title        = line_destination.split("/").last
      yaml_source       = "#{line_destination}/line.yml"

      unless File.exist?("#{yaml_source}")
        say("The current directory is not a valid line directory.", :red) and return
      end

      if !options[:input_data].nil? 
        input_data = "input/#{options[:input_data]}"
      else
        input_data = "input/#{run_title}.csv"
      end
      
      unless File.exist?(input_data)
        say("The input data csv file named #{input_data} is missing.", :red) and return
      end

      if set_target_uri
        # before starting the run creation process, we need to make sure whether the line exists or not
        # if not, then we got to first create the line and then do the production run
        # else we just simply do the production run
        if set_api_key(yaml_source)
          CF.account_name = CF::Account.info.name
          line = CF::Line.info(line_title)
          input_data_path = "#{Dir.pwd}/#{input_data}"
          if line.error.blank?
            say "Creating a production run with title #{run_title}", :green
            run = CF::Run.create(line, run_title, input_data_path)
            say "A run with title #{run.title} created successfully."
          else
            # first create line
            say "Creating the line: #{line_title}", :green
            Cf::Line.new.create
            # Now create a production run with the title run_title
            run = CF::Run.create(CF::Line.info(line_title), run_title, input_data_path)
            say "A run with title #{run.title} using the line #{line_title} was successfully created."
          end
        else
          say "The api_key is missing in the line.yml file", :red
        end
      else
        say "You have not set the target url.", :yellow
        say "cf target --url=http://sandbox.cloudfactory.com will set it to run on sandbox environment", :yellow
      end

    end
  end
end