module Cf
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      argument :account_name, :required => true,
                              :desc => "The account name that you used to signup at http://cloudfactory.com"
      argument :api_key, :required => true,
                              :desc => "The api key that you can find at the account settings page"

      desc "Creates a CF initializer"
      def generate_initializer
        say_status("Generating", "Cloud Factory initializer", :green)
        template "cloud_factory.rb", "config/initializers/cloud_factory.rb"
      end

      def show_readme
        readme 'README' if behavior == :invoke
      end

    end
  end  
end