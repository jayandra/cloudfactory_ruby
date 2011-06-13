module CF
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Creates a CF initializer"
      def generate_initializer
        say_status("Generating", "Cloud Factory initializer", :green)
        copy_file "cloud_factory.rb", "config/initializers/cloud_factory.rb"
      end
      
      def show_readme
        readme 'README' if behavior == :invoke
      end
      
    end
  end  
end