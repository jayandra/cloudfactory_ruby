require 'thor/group'

module Cf
  class Newform < Thor::Group
    include Thor::Actions
    include Cf::Config
    source_root File.expand_path('../templates', __FILE__)
    argument :form_title, :type => :string
    argument :line_title, :type => :string
    argument :labels, :type => :string
    argument :fields, :type => :hash
    
    def generate_form_template
      line_destination = "#{find_home}/.cf/#{line_title}"
      template("html_file.html.erb",   "#{line_destination}/#{form_title}.html")
      template("css_file.css.erb",     "#{line_destination}/#{form_title}.css")        
      template("js_file.js.erb",       "#{line_destination}/#{form_title}.js")
    end
  end
end

module Cf
  class Form < Thor
    include Cf::Config
    
    desc "form generate FORM-TITLE", "genarates a custom task form at ~/.cf/<line-title>/<form-title>.html and its associated css and js files"
    method_option :line, :type => :string, :required => true, :aliases => "-l", :desc => "the line title with which this form should be associated with"
    method_option :labels, :type => :string, :required => true, :aliases => "-lb", :desc => "the labels that will be shown to the worker on MTurk window"
    method_option :fields, :type => :hash, :required => true, :aliases => "-fd", :desc => "the actual form fields and types that the worker will work/fill on"
    method_option :force, :type => :boolean, :default => false, :aliases => "-f", :desc => "force to overwrite the files if the form already exists, default is false"
    
    def generate(form_title=nil)
      line_title = options[:line].underscore.dasherize
      line_destination = "#{find_home}/.cf/#{line_title}"
      
      if form_title.present?
        if Dir.exist?(line_destination)
          FileUtils.rm_rf("#{line_destination}/#{form_title}.*", :verbose => true) if options.force? && File.exist?("#{line_destination}/#{form_title}.html")
          if File.exist?("#{line_destination}/#{form_title}.html")
            say "Skipping the form because it already exists.\nUse the -f flag to force it to overwrite or check and delete it manually.", :red
          else
            say "Generating #{form_title} form for line: #{line_title}", :green
            Cf::Newform.start([form_title, line_title, options[:labels], options[:fields]])
            say "A new custom task form named #{form_title} created."
          end
        else
          say "The line with the name #{line_title} don't exist.\nFirst create a line with this name and generate the form.", :red
        end
      else
        say "Title for the form is required.", :red
      end
    end
  end
end