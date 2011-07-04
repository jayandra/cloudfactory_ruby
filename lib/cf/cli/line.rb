require 'thor/group'

module Cf
  class Newline < Thor::Group
    include Thor::Actions
    include Cf::Config
    source_root File.expand_path('../templates', __FILE__)
    argument :title, :type => :string, :desc => "The line title"
    argument :yaml_destination, :type => :string, :required => true
    # argument :with_custom_form
    
    def generate_line_template
      arr = yaml_destination.split("/")
      arr.pop
      line_destination = arr.join("/")
      template("line.tt", yaml_destination)
      # if with_custom_form
        copy_file("css_file.css.erb",     "#{line_destination}/css_file.css")
        copy_file("html_file.html.erb",   "#{line_destination}/html_file.html")
        copy_file("js_file.js.erb",       "#{line_destination}/js_file.js")
      # end
    end
  end
end

      
module Cf
  class Line < Thor
    include Cf::Config
    desc "line generate LINE-TITLE", "genarates a line template at ~/.cf/<line-title>/<line-title>.yml"
    method_option :force, :type => :boolean, :default => false, :aliases => "-f", :desc => "force to overwrite the files if the line already exists, default is false"
    # method_option :with_custom_form, :type => :boolean, :default => false, :aliases => "-wcf", :desc => "generate the template with custom task form and the sample files, default is true"
    
    def generate(title=nil)
      if title.present?
        line_destination = "#{find_home}/.cf/#{title.underscore.dasherize}"
        yaml_destination = "#{line_destination}/#{title.underscore.dasherize}.yml"
        FileUtils.rm_rf(line_destination, :verbose => true) if options.force? && File.exist?(line_destination)
        if File.exist?(line_destination)
          say "Skipping #{yaml_destination} because it already exists.\nUse the -f flag to force it to overwrite or check and delete it manually.", :red
        else
          say "Generating #{yaml_destination}", :green
          Cf::Newline.start([title, yaml_destination])
          say "A new line named #{title.underscore.dasherize} created."
        end
      else
        say "Title for the line is required.", :red
      end
    end
    
    desc "line create LINE-TITLE", "takes the yaml file at ~/.cf/<line-title>/<line-title>.yml file and creates a new line at http://cloudfactory.com"
    def create(title=nil)
      line_source = "#{find_home}/.cf/#{title.underscore.dasherize}"
      yaml_source = "#{line_source}/#{title.underscore.dasherize}.yml"
      unless title.present?
        say "Line-Title is required", :red
        return
      end
      unless File.exist?(yaml_source)
        say "Either the yml file is not present or doesn't match the title of the line with the filename.", :red
        return
      end
      
      line_creation_file = YAML::load(File.open(yaml_source))
      line_title = line_creation_file['title']
      line_department = line_creation_file['department']
      api_key = line_creation_file['api_key']

      line = CF::Line.new(line_title, line_department)
      say "New Line has been created with title => #{line.title} and Department => #{line.department_name}", :green

      # Creation of InputFormat from yaml file
      input_formats = line_creation_file['input_formats']
      input_formats.each do |input_format|
        attrs = {
          :name => input_format['input_format']['name'],
          :required => input_format['input_format']['required'],
          :valid_type => input_format['input_format']['valid_type']
        }
        input_format_for_line = CF::InputFormat.new(attrs)
        line.input_formats input_format_for_line
        say "New Input Format has been created with following attributes => #{attrs}", :green
      end

      # Creation of Station
      stations = line_creation_file['stations']
      stations.each do |station_file|
        type = station_file['station']['station_type']
        station = CF::Station.create(:line => line, :type => type) do |s|
          say "New Station has been created of type => #{s.type}", :green
          # Creation of Form
          # Creation of TaskForm
          if station_file['station']['task_form'].present?
            title = station_file['station']['task_form']['form_title']
            instruction = station_file['station']['task_form']['description']
            form = CF::TaskForm.create({:station => s, :title => title, :instruction => instruction}) do |f|
              say "New TaskForm has been created with Title => #{f.title} and Instruction => #{f.instruction}", :green
              # Creation of FormFields
              station_file['station']['task_form']['form_fields'].each do |form_field|
                field_type = form_field['form_field']['field_type']
                label = form_field['form_field']['label']
                required = form_field['form_field']['required']
                field = CF::FormField.new({:form => f, :label => label, :field_type => field_type, :required => required})
                say "New FormField has been created of label => #{field.label}, field_type => #{field.field_type} and required => #{field.required}", :green
              end
            end
          else
            # Creation of CustomTaskForm
            title = station_file['station']['custom_task_form']['form_title']
            instruction = station_file['station']['custom_task_form']['instruction']
            html_file = station_file['station']['custom_task_form']['html']
            html = File.read("#{line_source}/#{html_file}")
            css_file = station_file['station']['custom_task_form']['css']
            css = File.read("#{line_source}/#{css_file}")
            js_file = station_file['station']['custom_task_form']['js']
            js = File.read("#{line_source}/#{js_file}")
            form = CF::CustomTaskForm.create({:station => s, :title => title, :instruction => instruction, :raw_html => html, :raw_css => css, :raw_javascript => js})
            say "New CustomTaskForm has been created of line => #{form.title} and Description => #{form.instruction}.\nThe source file for html => #{html_file}, css => #{css_file} and js => #{js_file} ", :green
          end
          worker = station_file['station']['worker']
          number = worker['num_workers']
          reward = worker['reward']
          worker_type = worker['worker_type']
          if worker_type == "human"
            human_worker = CF::HumanWorker.new({:station => s, :number => number, :reward => reward})
            say "New Worker has been created of type => #{worker_type}, Number => #{number} and Reward => #{reward}", :green
          end
        end
      end
      say "Congrats! Since the line #{line_title} is setup, now you can do Production Runs on it.", :green
    end
  end
end