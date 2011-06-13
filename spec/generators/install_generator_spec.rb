require 'spec_helper'
require 'rails/all'
require 'rails/generators/test_case'
require 'generator_spec/test_case'

require 'generators/cf/install_generator'

module CF
  module Generators
    describe InstallGenerator, "using custom matcher" do
      include GeneratorSpec::TestCase
      destination File.expand_path("../tmp", __FILE__)

      before do
        prepare_destination
        run_generator
      end

      specify do
        run_generator
        destination_root.should have_structure {
          directory "config" do
            directory "initializers" do
              file "cloud_factory.rb" do
                contains "# CloudFactory Initializer"
              end
            end
          end
        }
      end
    end
  end
end