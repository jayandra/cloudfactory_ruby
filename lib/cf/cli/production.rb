require 'thor/group'

module Cf
  class Production < Thor
    include Cf::Config
    
    desc "production start", "creates a production run with parameterized file at input/<run-title>.csv"
    method_option :input_data, :type => :string, :required => true, :aliases => "-i", :desc => "the name of the input data file"
    method_option :title, :type => :string, :required => true, :aliases => "-t", :desc => "the title of the run"
    
    def start
      run_title         = options[:title].underscore.dasherize
      line_destination  = Dir.pwd
      input_data        = "#{line_destination}/input/#{options[:input_data]}"
      line_title        = line_destination.split("/").last
      yaml_source       = "#{line_destination}/line.yml"
      
      unless File.exist?("#{yaml_source}")
        say("The current directory is not a valid line directory.")
        return
      end
      
      unless File.exist?("input/#{run_title}.csv")
        say("The input data csv file named input/#{run_title}.csv is missing.", :red)
        return
      end
      
      if set_target_uri
        # before starting the run creation process, we need to make sure whether the line exists or not
        # if not, then we got to first create the line and then do the production run
        # else we just simply do the production run
        if set_api_key(yaml_source)
          CF.account_name = CF::Account.info.name
          line = CF::Line.info(line_title)
          input_data_path = "#{Dir.pwd}/input/#{run_title}.csv" 
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
            say "A run with title #{run.title} using the line #{line_title} created successfully."
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