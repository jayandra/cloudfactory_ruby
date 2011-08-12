require 'spec_helper'
require 'rails/all'
require 'rails/generators/test_case'
require 'generator_spec/test_case'

require 'generators/cf/install/install_generator'

module Cf # :nodoc: all
  module Generators # :nodoc: all
    describe InstallGenerator, "using custom matcher" do
      include GeneratorSpec::TestCase
      destination File.expand_path("../tmp", __FILE__)
      
      before do
        prepare_destination
        run_generator
      end

      specify "should generate the initializer for a rails app" do
        run_generator
        destination_root.should have_structure {
          directory "config" do
            directory "initializers" do
              file "cloudfactory.rb" do
                contains "# CloudFactory Initializer"
                contains "your-api-key"
              end
            end
          end
        }
      end
    end
  end
end