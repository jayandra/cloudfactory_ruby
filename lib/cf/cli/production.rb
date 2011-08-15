require 'thor/group'

module Cf # :nodoc: all
  class Production < Thor # :nodoc: all
    include Cf::Config
    
    no_tasks do
      def extract_name(file_path)
        Pathname.new(file_path).basename.to_s
      end
    end
    
    desc "production start <run-title>", "creates a production run with input data file at input/<run-title>.csv"
    method_option :input_data, :type => :string, :aliases => "-i", :desc => "the name of the input data file"
    method_option :live, :type => :boolean, :default => false, :aliases => "-l", :desc => "force the host to set to live mturk environment"
    def start(title=nil)
      
      line_destination  = Dir.pwd
      yaml_source       = "#{line_destination}/line.yml"
      
      unless File.exist?("#{yaml_source}")
        say("The current directory is not a valid line directory.", :red) and return
      end

      line_yaml_dump = YAML::load(File.open(yaml_source))
      line_title = line_yaml_dump['title'].parameterize

      if title.nil?
        run_title       = "#{line_title}-#{Time.new.strftime('%y%b%e-%H%M%S')}"
      else
        run_title       = "#{title.parameterize}-#{Time.new.strftime('%y%b%e-%H%M%S')}"
      end

      if !options[:input_data].nil?
        input_data = "input/#{options[:input_data]}"
      else
        input_data_dir = "#{line_destination}/input"
        input_files = Dir["#{input_data_dir}/*.csv"]
        file_count = input_files.size
        case file_count
        when 0
          say("No input data file present inside the input folder", :red) and return
        when 1
          input_data = "input/#{extract_name(input_files.first)}"
        else
          # Let the user choose the file
          chosen_file = nil
          choose do |menu|
            menu.header = "Input data files"
            menu.prompt = "Please choose which file to be used as input data"

            input_files.each do |item|
              menu.choice(extract_name(item)) do
                chosen_file = extract_name(item)
                say("Using the file #{chosen_file} as input data")
              end
            end
          end
          input_data = "input/#{chosen_file}"
        end
      end
      
      unless File.exist?(input_data)
        say("The input data file named #{input_data} is missing.", :red) and return
      end
      
      set_target_uri(options[:live])
      # before starting the run creation process, we need to make sure whether the line exists or not
      # if not, then we got to first create the line and then do the production run
      # else we just simply do the production run
      set_api_key(yaml_source)
      CF.account_name = CF::Account.info.name
      line = CF::Line.info(line_title)
      input_data_file = "#{Dir.pwd}/#{input_data}"
      if line.error.blank?
        say "Creating a production run with title #{run_title}.", :green
        run = CF::Run.create(line, run_title, input_data_file)
        if run.errors.blank?
          say("Run created successfully.", :green)
          say("View your run at http://#{CF.account_name}.#{CF.api_url.split("/")[-2]}/runs/#{CF.account_name}/#{run.title}\n", :yellow)
        else
          say("Error: #{run.errors}", :red)
        end
      else
        # first create line
        say("Creating the line: #{line_title}", :green)
        Cf::Line.new.create
        # Now create a production run with the title run_title
        say "Creating a production run with title #{run_title}.", :green
        run = CF::Run.create(CF::Line.info(line_title), run_title, input_data_file)
        if run.errors.blank?
          say("Run created successfully.", :green)
          say("View your run at http://#{CF.account_name}.#{CF.api_url.split("/")[-2]}/runs/#{CF.account_name}/#{run.title}\n", :yellow)
        else
          say("Error: #{run.errors}", :red)
        end
      end
    end

    desc "production list", "list the production runs"
    method_option :line, :type => :string, :aliases => "-l", :desc => "the title of the line"
    def list
      set_target_uri(false)
      set_api_key
      CF.account_name = CF::Account.info.name
      if options['line'].present?
        runs = CF::Run.all(options['line'].parameterize)
      else
        runs = CF::Run.all
      end

      unless runs.kind_of?(Array)
        if runs.error.present?
          say("No Runs\n#{runs.error.message}", :red) and exit(1)
        end
      end

      runs.sort! {|a, b| a[:name] <=> b[:name] }
      runs_table = table do |t|
        t.headings = ["Run Title", 'URL']
        runs.each do |run|
          t << [run.title, "http://#{CF.account_name}.cloudfactory.com/runs/#{CF.account_name}/#{run.title}"]
        end
      end
      say("\n")
      say(runs_table)
    end
  end
end