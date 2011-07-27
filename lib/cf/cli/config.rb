module Cf
  module Config
    def config_file
      File.join(find_home, '.cf_credentials')
    end

    def load_config
      YAML::load(File.read(config_file)) if File.exist?(config_file)
    end

    def save_config(target_url)
      if target_url == "staging"
        target_set_url = "http://sandbox.staging.cloudfactory.com/api/"
      elsif target_url == "development"
        target_set_url = "http://lvh.me:3000/api/"
      elsif target_url == "production"
        target_set_url = "http://sandbox.cloudfactory.com/api/"
      end
      File.open(config_file, 'w') {|f| f.write({ :target_url => "#{target_set_url}", :api_version => "v1" }.to_yaml) }
      return target_set_url
    end

    def set_target_uri(live)
      if load_config
        CF.api_url = load_config[:target_url]
        CF.api_version = load_config[:api_version]
      else
        CF.api_url = "http://sandbox.cloudfactory.com/api"
        CF.api_version = "v1"
      end

      if live
        if CF.api_url == "http://sandbox.staging.cloudfactory.com/api"  
          CF.api_url = "http://staging.cloudfactory.com/api"
        end

        if CF.api_url == "http://sandbox.cloudfactory.com/api"
          CF.api_url = "http://cloudfactory.com/api"
        end
      end
    end
    
    def get_api_key(line_yaml_file)
      line_yml = YAML::load(File.read(line_yaml_file))
      line_yml['api_key'].presence
    end
    
    def set_api_key(yaml_source)
      # debugger
      api_key = get_api_key(yaml_source)
      if api_key.blank?
        return false
      else
        CF.api_key = api_key if CF.api_key.blank?
        return true
      end
    end
    
    # Ripped from rubygems
    unless ENV['TEST_CLI']
      def find_home
        unless RUBY_VERSION > '1.9' then
          ['HOME', 'USERPROFILE'].each do |homekey|
            return File.expand_path(ENV[homekey]) if ENV[homekey]
          end

          if ENV['HOMEDRIVE'] && ENV['HOMEPATH'] then
            return File.expand_path("#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}")
          end
        end

        File.expand_path "~"
      rescue
        if File::ALT_SEPARATOR then
          drive = ENV['HOMEDRIVE'] || ENV['SystemDrive']
          File.join(drive.to_s, '/')
        else
          "/"
        end
      end
    else
      def find_home
        File.expand_path(File.dirname(__FILE__) + '/../../../tmp/aruba')
      end
    end
  end
end