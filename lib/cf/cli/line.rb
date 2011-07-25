  require 'thor/group'

module Cf
  class Newline < Thor::Group
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

      
module Cf
  class Line < Thor
    include Cf::Config
    desc "line generate LINE-TITLE", "genarates a line template at <line-title>/line.yml"
    method_option :force, :type => :boolean, :default => false, :aliases => "-f", :desc => "force to overwrite the files if the line already exists, default is false"
    # method_option :with_custom_form, :type => :boolean, :default => false, :aliases => "-wcf", :desc => "generate the template with custom task form and the sample files, default is true"
    
    def generate(title=nil)
      if title.present?
        line_destination = "#{title.underscore.dasherize}"
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
    
    desc "line create", "takes the yaml file at line.yml and creates a new line at http://cloudfactory.com"
    def create
      line_source = Dir.pwd
      yaml_source = "#{line_source}/line.yml"
      
      unless File.exist?(yaml_source)
        say "The line.yml file does not exist in this directory", :red
        return
      end
      
      if set_target_uri
        if set_api_key(yaml_source)

          CF.account_name = CF::Account.info.name
        
          line_dump = YAML::load(File.open(yaml_source))
          line_title = line_dump['title']
          line_description = line_dump['description']
          line_department = line_dump['department']
          line = CF::Line.new(line_title, line_department, :description => line_description)
          say "New Line has been created with title => #{line.title} and Department => #{line.department_name}", :green

          # Creation of InputFormat from yaml file
          input_formats = line_dump['input_formats']
          input_formats.each do |input_format|
            attrs = {
              :name => input_format['name'],
              :required => input_format['required'],
              :valid_type => input_format['valid_type']
            }
            input_format_for_line = CF::InputFormat.new(attrs)
            line.input_formats input_format_for_line
            say "New Input Format has been created with following attributes => #{attrs}", :green
          end

          # Creation of Station
          stations = line_dump['stations']
          stations.each do |station_file|
            type = station_file['station']['station_type']
            input_formats_for_station = station_file['station']['input_formats']
            if type == "tournament"
              max_judges = station_file['station']['max_judges']
              auto_judge = station_file['station']['auto_judge']
              station_params = {:line => line, :type => type, :max_judges => max_judges, :auto_judge => auto_judge, :input_formats => input_formats_for_station}
            else
              station_params = {:line => line, :type => type, :input_formats => input_formats_for_station}
            end
            station = CF::Station.create(station_params) do |s|
              say "New Station has been created of type => #{s.type}", :green
              # Creation of Form
              # Creation of TaskForm
              if station_file['station']['task_form'].present?
                title = station_file['station']['task_form']['form_title']
                instruction = station_file['station']['task_form']['instruction']
                form = CF::TaskForm.create({:station => s, :title => title, :instruction => instruction}) do |f|
                  say "New TaskForm has been created with Title => #{f.title} and Instruction => #{f.instruction}", :green
                  # Creation of FormFields
                  station_file['station']['task_form']['form_fields'].each do |form_field|
                    field_type = form_field['field_type']
                    label = form_field['label']
                    required = form_field['required']
                    field = CF::FormField.new({:form => f, :label => label, :field_type => field_type, :required => required})
                    say "New FormField has been created of label => #{field.label}, field_type => #{field.field_type} and required => #{field.required}", :green
                  end
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
              
                say "New CustomTaskForm has been created of line => #{form.title} and Description => #{form.instruction}.\nThe source file for html => #{html_file}, css => #{css_file} and js => #{js_file} ", :green
              end
              
              # For Worker
              worker = station_file['station']['worker']
              number = worker['num_workers']
              reward = worker['reward']
              worker_type = worker['worker_type']
              if worker_type == "human"
                human_worker = CF::HumanWorker.new({:station => s, :number => number, :reward => reward})
                say "New Worker has been created of type => #{worker_type}, Number => #{number} and Reward => #{reward}", :green
              else
                robot_type = ("CF::"+worker_type.camelize).constantize
                settings = worker['settings']
                robot_params = settings.merge(:station => s)
                robot_worker = robot_type.create(robot_params.symbolize_keys)
    
                say "New Worker has been created of type => #{ worker['settings']}", :green
              end
            end
          end
          say "Congrats! Since the line #{line_title} is setup, now you can start the production using it.", :green
          say "You can check your line at https://#{CF.account_name}.cloudfactory.com/lines/#{CF.account_name}/#{line.title}", :yellow
          say "Now you can do your production run with: cf production start --title=<your_run_title> --input-data=input_data.csv", :green
          say "Note: Make sure input_data.csv file is in the inputs directory.", :green
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