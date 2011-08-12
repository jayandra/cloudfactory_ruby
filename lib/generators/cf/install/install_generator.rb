module Cf # :nodoc: all
  module Generators # :nodoc: all
    class InstallGenerator < Rails::Generators::Base # :nodoc: all
      source_root File.expand_path("../templates", __FILE__)

      desc "Creates a CF initializer"
      def generate_initializer
        say_status("Generating", "CloudFactory initializer", :green)
        template "cloudfactory.rb", "config/initializers/cloudfactory.rb"
      end

      def show_readme
        readme 'README' if behavior == :invoke
      end

    end
  end
end