module Cf # :nodoc: all
  module Generators # :nodoc: all
    class InstallGenerator < Rails::Generators::Base # :nodoc: all
      source_root File.expand_path("../templates", __FILE__)
      # argument :account_name, :required => true,
      #                         :desc => "The account name that you used to signup at http://cloudfactory.com"
      argument :api_key, :required => true,
                              :desc => "Your API key(s) can be found at http://cloudfactory.com/account#settings"

      desc "Creates a CF initializer"
      def generate_initializer
        say_status("Generating", "CloudFactory initializer", :green)
        template "cloud_factory.rb", "config/initializers/cloud_factory.rb"
      end

      def show_readme
        readme 'README' if behavior == :invoke
      end

    end
  end
end