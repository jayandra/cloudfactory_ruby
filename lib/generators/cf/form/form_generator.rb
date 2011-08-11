module Cf # :nodoc: all
  module Generators # :nodoc: all

    #
    # TODO: if the parameter like 'company' below is not provided, then its a survey form.
    # But how to name it is not defined. If we just use survey_name,
    # then it might collide if the developer generates another survey form
    #
    # => rails generate cf:form company ceo:string Website:url
    #
    # <label>{{company}}</label>
    # <p><label>ceo</label><input id="ceo" type="text" name="output[ceo]" data-valid-type="string" /></p>
    # <p><label>Website</label><input id="website" type="text" name="output[website]" data-valid-type="url" /></p>
    #
    #
    # => rails generate cf:form [company,website] CEO:string Website:url
    #
    # <label>{{company}}</label>
    # <label>{{website}}</label>
    # <p><label>CEO</label><input id="ceo" type="text" name="output[ceo]" data-valid-type="string" /></p>
    # <p><label>Website</label><input id="website" type="text" name="output[website]" data-valid-type="url" /></p>
    #
    #

    class FormGenerator < Rails::Generators::Base # :nodoc: all
      source_root File.expand_path("../templates", __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "[label1,label2] field:type field:type"

      desc "Generates a CloudFactory CustomTaskForm"
      def generate_form
        @labels = nil

        attributes.detect {|item| @labels = item.match(/^\[(.*)\]$/) }

        @labels = @labels.to_a.last unless @labels.nil?
        attributes.delete(attributes.first) unless @labels.nil?

        file_name = make_file_name(@labels)

        say_status("Generating", "CloudFactory CustomTaskForm", :green)
        template "cf_form.html.erb", "app/cf_forms/#{file_name}"
      end

      private

      def make_file_name(attrs)
        if attrs.nil?
          "custom_task_form.html"
        else
          attrs.split(",").join("_") + "_form.html"
        end
      end
    end
  end
end