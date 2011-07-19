require 'thor/group'

module Cf
  class Production < Thor
    include Cf::Config
    
    desc "production start --title=the_run_title", "creates a production run with the files at <line-title>/ and its associated files and input data"
    method_option :input_data, :type => :string, :required => true, :aliases => "-i", :desc => "the name of the input data file"
    method_option :title, :type => :string, :required => true, :aliases => "-t", :desc => "the title of the run"
    
    def start
      run_title             = options[:title].underscore.dasherize
      line_destination  = Dir.pwd
      input_data        = "#{line_destination}/input/#{options[:input_data]}"      
      line_title        = line_destination.split("/").last
      yaml_source       = "#{line_destination}/line.yml"
      
      unless File.exist?("#{yaml_source}")
        say("The current directory is not a valid line directory.")
        return
      end
      
      # before starting the run creation process, we need to make sure whether the line exists or not
      # if not, then we got to first create the line and then do the production run
      # else we just simply do the production run
      if set_api_key(yaml_source)
        CF.account_name = CF::Account.info.name
        line = CF::Line.info(line_title)
        
        if line.error.blank?
          say "Creating a production run with title #{run_title}", :green
          run = CF::Run.create(line, run_title, input_data)
          say "A run with title #{run.title} created successfully."
        else
          # first create line
          say "Creating the line: #{line_title}", :green
          Cf::Line.new.create
          # Now create a production run with the title run_title
          run = CF::Run.create(CF::Line.info(line_title), run_title, input_data)
          say "A run with title #{run.title} using the line #{line_title} created successfully."
        end
      else
        say "The api_key is missing in the line.yml file", :red
      end
    end
  end
end