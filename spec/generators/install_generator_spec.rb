require 'spec_helper'
require 'rails/all'
require 'rails/generators/test_case'
require 'generator_spec/test_case'

require 'generators/cf/install/install_generator'

module Cf
  module Generators
    describe InstallGenerator, "using custom matcher" do
      include GeneratorSpec::TestCase
      destination File.expand_path("../tmp", __FILE__)
      arguments %w(valid_api_key)
      
      before do
        prepare_destination
        run_generator
      end

      specify "should generate the initializer for a rails app" do
        run_generator
        destination_root.should have_structure {
          directory "config" do
            directory "initializers" do
              file "cloud_factory.rb" do
                contains "# CloudFactory Initializer"
                contains "valid_api_key"
              end
            end
          end
        }
      end
    end
  end
end