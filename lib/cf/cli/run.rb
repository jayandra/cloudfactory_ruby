require 'thor/group'

module Cf
  class Run < Thor
    include Cf::Config
    
    desc "run create LINE-TITLE", "creates a production run with the files at ~/.cf/<line-title>/ and its associated files and input data"
    method_option :input_data, :type => :string, :required => true, :aliases => "-i", :desc => "the name of the input data file"
    method_option :line, :type => :string, :required => true, :aliases => "-l", :desc => "the title of the line upon which the Run will be created"
    
    def create(run_title=nil)
      line_title        = options[:line].underscore.dasherize
      input_data        = options[:input_data]
      line_destination  = "#{find_home}/.cf/#{line_title}"
      yaml_source       = "#{line_destination}/#{line_title}.yml"
      
      if run_title.present?
        if Dir.exist?(line_destination)
          if File.exist?(yaml_source)
            # before starting the run creation process, we need to make sure whether the line exists or not
            # if not, then we got to first create the line and then do the production run
            # else we just simply do the production run
            if set_api_key(yaml_source)
              CF.account_name = CF::Account.info.name
              line = CF::Line.info(line_title)
              if line.error.blank?
                say "Creating a production run with title #{run_title} using the line: #{line_title}", :green
                run = CF::Run.create(line, run_title, "#{line_destination}/#{input_data}")
                say "A run with title #{run.title} using the line #{line.title} created successfully."
              else
                # first create line
                say "Creating the line: #{line_title}", :green
                Cf::Line.new.create(line_title)
                # Now create a production run with the title run_title
                run = CF::Run.create(CF::Line.info(line_title), run_title, "#{line_destination}/#{input_data}")
                say "A run with title #{run.title} using the line #{line_title} created successfully."
              end
            else
              say "The api_key is missing in the line #{yaml_source} file", :red
            end
          else
            say "The yaml file with the name #{line_title}.yml is missing.\nFirst generate a line which will in turn generates a yml file which you can update specific to your need.\Then you can create a production run.", :red
          end
        else
          say "The line with the name #{line_title} doesn't exist.\nFirst create a line with this name and make a production run.", :red
        end
      else
        say "The Run title is required so that you can trace the results using this title.", :red
      end
    end
  end
end