# encoding: utf-8
require 'thor/group'

module Cf # :nodoc: all
  class Newline < Thor::Group # :nodoc: all
    include Thor::Actions
    include Cf::Config
    source_root File.expand_path('../templates/', __FILE__)
    argument :title, :type => :string, :desc => "The line title"
    argument :yaml_destination, :type => :string, :required => true

    def generate_line_template
      arr = yaml_destination.split("/")
      arr.pop
      line_destination = arr.join("/")
      template("sample-line/line.yml.erb", yaml_destination)
      copy_file("sample-line/form.css",    "#{line_destination}/station_2/form.css")
      copy_file("sample-line/form.html",   "#{line_destination}/station_2/form.html")
      copy_file("sample-line/form.js",     "#{line_destination}/station_2/form.js")
      copy_file("sample-line/sample-line.csv",        "#{line_destination}/input/#{title.underscore.dasherize}.csv")
      FileUtils.mkdir("#{line_destination}/output")
    end
  end
end


module Cf # :nodoc: all
  class Line < Thor # :nodoc: all
    include Cf::Config
    desc "line generate LINE-TITLE", "generates a line template at <line-title>/line.yml"
    method_option :force, :type => :boolean, :default => false, :aliases => "-f", :desc => "force to overwrite the files if the line already exists, default is false"
    # method_option :with_custom_form, :type => :boolean, :default => false, :aliases => "-wcf", :desc => "generate the template with custom task form and the sample files, default is true"

    def generate(title=nil)
      if title.present?
        line_destination = "#{title.parameterize}"
        yaml_destination = "#{line_destination}/line.yml"
        FileUtils.rm_rf(line_destination, :verbose => true) if options.force? && File.exist?(line_destination)
        if File.exist?(line_destination)
          say "Skipping #{yaml_destination} because it already exists.\nUse the -f flag to force it to overwrite or check and delete it manually.", :red
        else
          say "Generating #{yaml_destination}", :green
          Cf::Newline.start([title, yaml_destination])
          say "A new line named #{line_destination} generated.", :green
          say "Modify the #{yaml_destination} file and you can create this line with: cf line create", :yellow
        end
      else
        say "Title for the line is required.", :red
      end
    end

    desc "line delete", "delete the line at http://cloudfactory.com"
    def delete
      line_source = Dir.pwd
      yaml_source = "#{line_source}/line.yml"

      unless File.exist?(yaml_source)
        say("The line.yml file does not exist in this directory", :red) and return
      end

      set_target_uri(false)
      set_api_key(yaml_source)
      CF.account_name = CF::Account.info.name
      line_dump = YAML::load(File.open(yaml_source))
      line_title = line_dump['title'].parameterize

      CF::Line.destroy(line_title)
      say("The line #{line_title} was deleted successfully!", :yellow)
    end

    no_tasks {
      # method to call with line title to delete the line if validation fails during the creation of line
      def rollback(line_title)
        CF::Line.destroy(line_title)
      end
    }
    
    desc "line create", "takes the yaml file at line.yml and creates a new line at http://cloudfactory.com"
    def create
      line_source = Dir.pwd
      yaml_source = "#{line_source}/line.yml"

      unless File.exist?(yaml_source)
        say "The line.yml file does not exist in this directory", :red
        return
      end

      set_target_uri(false)
      set_api_key(yaml_source)

        CF.account_name = CF::Account.info.name

        line_dump = YAML::load(File.open(yaml_source))
        line_title = line_dump['title'].parameterize
        line_description = line_dump['description']
        line_department = line_dump['department']
        line = CF::Line.new(line_title, line_department, :description => line_description)

        say("#{line.errors}", :red); rollback(line_title) and return if line.errors.present?
        
        say "Creating new assembly line: #{line.title}", :green
        say "Adding InputFormats", :green

        # Creation of InputFormat from yaml file
        input_formats = line_dump['input_formats']
        input_formats.each_with_index do |input_format, index|
          
          attrs = {
            :name => input_format['name'],
            :required => input_format['required'],
            :valid_type => input_format['valid_type']
          }
          input_format_for_line = CF::InputFormat.new(attrs)
          input_format = line.input_formats input_format_for_line
          say_status "input", "#{attrs[:name]}"
          
          say("#{line.input_formats[index].errors}", :red); rollback(line_title) and return if line.input_formats[index].errors.present?
        end

        # Creation of Station
        stations = line_dump['stations']
        stations.each do |station_file|
          type = station_file['station']['station_type']
          index = station_file['station']['station_index']
          input_formats_for_station = station_file['station']['input_formats']
          if type == "tournament"
            jury_worker = station_file['station']['jury_worker']
            auto_judge = station_file['station']['auto_judge']
            station_params = {:line => line, :type => type, :jury_worker => jury_worker, :auto_judge => auto_judge, :input_formats => input_formats_for_station}
          else
            station_params = {:line => line, :type => type, :input_formats => input_formats_for_station}
          end
          station = CF::Station.create(station_params) do |s|
            #say "New Station has been created of type => #{s.type}", :green
            
            say("#{s.errors}", :red); rollback(line_title) and return if s.errors.present?
            
            say "Adding Station #{index}: #{s.type}", :green
            # For Worker
            worker = station_file['station']['worker']
            number = worker['num_workers']
            reward = worker['reward']
            worker_type = worker['worker_type']
            if worker_type == "human"
              skill_badges = worker['skill_badges']
              stat_badge = worker['stat_badge']
              if stat_badge.nil?
                human_worker = CF::HumanWorker.new({:station => s, :number => number, :reward => reward})
              else
                human_worker = CF::HumanWorker.new({:station => s, :number => number, :reward => reward, :stat_badge => stat_badge})
              end
              
              say("#{human_worker.errors}", :red); rollback(line_title) and return if human_worker.errors.present?
              
              if worker['skill_badges'].present?
                skill_badges.each do |badge|
                  human_worker.badge = badge
                end
              end
              #say "New Worker has been created of type => #{worker_type}, Number => #{number} and Reward => #{reward}", :green
              say_status "worker", "#{number} Cloud #{pluralize(number, "Worker")} with reward of #{reward} #{pluralize(reward, "cent")}"
            elsif worker_type =~ /robot/
              settings = worker['settings']
              robot_worker = CF::RobotWorker.create({:station => s, :type => worker_type, :settings => settings})
              
              say("#{robot_worker.errors}", :red) and return if robot_worker.errors.present?
              say_status "robot", "Robot worker: #{worker_type}"
            else
              say("Invalid worker type: #{worker_type}", :red); rollback(line_title) and return
            end

            # Creation of Form
            # Creation of TaskForm
            if station_file['station']['task_form'].present?
              title = station_file['station']['task_form']['form_title']
              instruction = station_file['station']['task_form']['instruction']
              form = CF::TaskForm.create({:station => s, :title => title, :instruction => instruction}) do |f|
                # Creation of FormFields
                station_file['station']['task_form']['form_fields'].each do |form_field|
                  form_field_params = form_field.merge(:form => f)
                  field = CF::FormField.new(form_field_params.symbolize_keys)
                  say("Error in form field: #{field.errors}", :red); rollback(line_title) and return if field.errors.present?
                end
                say_status "form", "TaskForm '#{f.title}'"
              end

            elsif station_file['station']['custom_task_form'].present?
              # Creation of CustomTaskForm
              title = station_file['station']['custom_task_form']['form_title']
              instruction = station_file['station']['custom_task_form']['instruction']

              html_file = station_file['station']['custom_task_form']['html']
              html = File.read("#{line_source}/station_#{station_file['station']['station_index']}/#{html_file}")
              css_file = station_file['station']['custom_task_form']['css']
              css = File.read("#{line_source}/station_#{station_file['station']['station_index']}/#{css_file}")
              js_file = station_file['station']['custom_task_form']['js']
              js = File.read("#{line_source}/station_#{station_file['station']['station_index']}/#{js_file}")
              form = CF::CustomTaskForm.create({:station => s, :title => title, :instruction => instruction, :raw_html => html, :raw_css => css, :raw_javascript => js})

              say_status "form", "CustomTaskForm '#{form.title}'"
            end

          end
        end
        say " ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁ ☁", :white
        say "Line was successfully created.", :green
        say "View your line at http://#{CF.account_name}.#{CF.api_url.split("/")[-2]}/lines/#{CF.account_name}/#{line.title}", :yellow
        say "\nNow you can do production runs with: cf production start <your_run_title>", :green
        say "Note: Make sure your-run-title.csv file is in the input directory.", :green
    end

    desc "line list", "List your lines"
    def list
      line_source = Dir.pwd
      yaml_source = "#{line_source}/line.yml"

      set_target_uri(false)
      set_api_key(yaml_source)
      CF.account_name = CF::Account.info.name
      lines = CF::Line.all
      lines.sort! {|a, b| a[:name] <=> b[:name] }
      say "\n"
      say("No Lines", :yellow) if lines.blank?

      lines_table = table do |t|
        t.headings = ["Line Title", 'URL']
        lines.each do |line|
          t << [line.title, "http://#{CF.account_name}.cloudfactory.com/lines/#{CF.account_name}/#{line.title.parameterize}"]
        end
      end
      say(lines_table)
    end

    # helper function like in Rails
    no_tasks {
      def pluralize(number, text)
        return text.pluralize if number != 1
        text
      end
    }

  end
end