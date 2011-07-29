require 'spec_helper'
require 'rails/all'
require 'rails/generators/test_case'
require 'generator_spec/test_case'

require 'generators/cf/form/form_generator'

module Cf
  module Generators
    describe FormGenerator, "Passing both the Labels and Field:Type" do
      include GeneratorSpec::TestCase
      destination File.expand_path("../tmp", __FILE__)
      arguments %w([company,website] CEO:string Website:url)
      
      before { prepare_destination }
      
      specify "should generate the custom task form for a rails app with labels and fields" do
        run_generator
        destination_root.should have_structure {
          directory "app" do
            directory "cf_forms" do
              file "company_website_form.html" do
                contains "<!-- CloudFactory Custom Task Form -->"
                contains "<label>{{company}}</label>"
                contains "<label>{{website}}</label>"
                contains '<p><label>CEO</label><input id="ceo" type="text" name="output[ceo]" data-valid-type="string" /></p>'
                contains '<p><label>Website</label><input id="website" type="text" name="output[website]" data-valid-type="url" /></p>'
              end
            end
          end
        }
      end
    end

    describe FormGenerator, "Passing only the Field:Type without Label. e.g. for forms like Survey" do
      include GeneratorSpec::TestCase
      destination File.expand_path("../tmp", __FILE__)
      arguments %w(CEO:string Website:url)
      
      before { prepare_destination }
      
      specify "should generate the custom task form for a rails app with fields only" do
        run_generator
        destination_root.should have_structure {
          directory "app" do
            directory "cf_forms" do
              file "custom_task_form.html" do
                contains "<!-- CloudFactory Custom Task Form -->"
                contains '<p><label>CEO</label><input id="ceo" type="text" name="output[ceo]" data-valid-type="string" /></p>'
                contains '<p><label>Website</label><input id="website" type="text" name="output[website]" data-valid-type="url" /></p>'
              end
            end
          end
        }
      end
    end


  end
end