require 'thor/group'

module Cf
  class Newform < Thor::Group
    include Thor::Actions
    include Cf::Config
    source_root File.expand_path('../templates', __FILE__)
    argument :station, :type => :numeric
    argument :labels, :type => :string
    argument :fields, :type => :hash

    def generate_form_template
      line_destination = Dir.pwd
      template("html_file.html.erb",   "#{line_destination}/station_#{station}/form.html")
      template("css_file.css.erb",     "#{line_destination}/station_#{station}/form.css")
      template("js_file.js.erb",       "#{line_destination}/station_#{station}/form.js")
    end
  end

  class FormPreview < Thor::Group
    include Thor::Actions
    include Cf::Config
    source_root File.expand_path('../templates', __FILE__)
    argument :station, :type => :numeric
    argument :form_content, :type => :string

    def generate_form_preview
      line_destination = Dir.pwd
      template("form_preview.html.erb",   "#{line_destination}/station_#{station}/form_preview.html")
    end

    def launch_preview
      line_destination = Dir.pwd
      system "open #{line_destination}/station_#{station}/form_preview.html"
    end
  end
end

module Cf
  class Form < Thor
    include Cf::Config

    desc "form generate", "generates a custom task form at <line-title>/<form-title>.html and its associated css and js files"
    method_option :station, :type => :numeric, :required => true, :aliases => "-st", :desc => "the station index this form should be associated with"
    method_option :labels, :type => :string, :required => true, :aliases => "-lb", :desc => "the labels that will be shown to the worker on MTurk window"
    method_option :fields, :type => :hash, :required => true, :aliases => "-fd", :desc => "the actual form fields that the worker will fill in"
    method_option :force, :type => :boolean, :default => false, :aliases => "-f", :desc => "force to overwrite the files if the form already exists, default is false"

    def generate
      line_destination = Dir.pwd
      unless File.exist?("#{line_destination}/line.yml")
        say("The current directory is not a valid line directory.", :red) and return
      end

      FileUtils.rm_rf("#{line_destination}/station_#{options[:station]}", :verbose => true) if options.force? && Dir.exist?("#{line_destination}/station_#{options[:station]}")
      if Dir.exist?("#{line_destination}/station_#{options[:station]}")
        say "Skipping the form generation because the station_#{options[:station]} already exists with its custom form.\nUse the -f flag to force it to overwrite or check and delete the station_#{options[:station]} folder manually.", :red
      else
        say "Generating form for station #{options[:station]}", :green
        Cf::Newform.start([options[:station], options[:labels], options[:fields]])
        say "A new custom task form created in station_#{options[:station]}."
      end
    end

    desc "form preview", "generates a html file to preview the custom task form"
    method_option :station, :type => :numeric, :required => true, :aliases => "-s", :desc => "station index of the form to preview"
    def preview
      line_destination = Dir.pwd
      unless File.exist?("#{line_destination}/line.yml")
        say("The current directory is not a valid line directory.", :red) and return
      end
      if Dir.exist?("#{line_destination}/station_#{options[:station]}") and !Dir["#{line_destination}/station_#{options[:station]}/*"].empty?
        say "Generating preview form for station #{options[:station]}", :green
        form_content = File.read("station_#{options[:station]}/form.html")
        Cf::FormPreview.start([options[:station], form_content])
      else
        say "No form exists for station #{options[:station]}", :red
        say "Generate the form for station 2 and then preview it.", :red
      end
    end
  end
end