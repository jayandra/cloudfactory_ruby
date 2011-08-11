require 'thor/group'

module Cf # :nodoc: all
  class Production < Thor # :nodoc: all
    include Cf::Config

    desc "production start <run-title>", "creates a production run with input data file at input/<run-title>.csv"
    method_option :input_data, :type => :string, :aliases => "-i", :desc => "the name of the input data file"
    method_option :live, :type => :boolean, :default => false, :aliases => "-l", :desc => "force the host to set to live mturk environment"
    def start(title=nil)
      
      if title.nil?
        say("The run title is required to start the production.", :red) and return
      end
      
      run_title         = title.parameterize
      line_destination  = Dir.pwd
      yaml_source       = "#{line_destination}/line.yml"
      
      unless File.exist?("#{yaml_source}")
        say("The current directory is not a valid line directory.", :red) and return
      end

      line_yaml_dump = YAML::load(File.open(yaml_source))
      line_title = line_yaml_dump['title'].parameterize

      if !options[:input_data].nil? 
        input_data = "input/#{options[:input_data]}"
      else
        input_data = "input/#{run_title}.csv"
      end
      
      unless File.exist?(input_data)
        say("The input data csv file named #{input_data} is missing.", :red) and return
      end
      
      set_target_uri(options[:live])
      # before starting the run creation process, we need to make sure whether the line exists or not
      # if not, then we got to first create the line and then do the production run
      # else we just simply do the production run
      set_api_key(yaml_source)
      CF.account_name = CF::Account.info.name
      line = CF::Line.info(line_title)
      input_data_path = "#{Dir.pwd}/#{input_data}"
      if line.error.blank?
        say "Creating a production run with title #{run_title}", :green
        run = CF::Run.create(line, run_title, input_data_path)
        if run.errors.blank?
          say("A run with title #{run.title} created successfully.", :green)
          say("View your run at http://#{CF.account_name}.#{CF.api_url.split("/")[-2]}/runs/#{CF.account_name}/#{run.title}", :yellow)
        else
          say("Error: #{run.errors}", :red)
        end
      else
        # first create line
        say("Creating the line: #{line_title}", :green)
        Cf::Line.new.create
        # Now create a production run with the title run_title
        run = CF::Run.create(CF::Line.info(line_title), run_title, input_data_path)
        if run.errors.blank?
          say("A run with title #{run.title} using the line #{line_title} was successfully created.", :red)
        else
          say("Error: #{run.errors}", :red)
        end
      end
    end
  end
end