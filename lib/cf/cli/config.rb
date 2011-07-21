module Cf
  module Config
    def config_file
      File.join(find_home, '.cf_credentials')
    end

    def load_config
      YAML::load(File.read(config_file)) if File.exist?(config_file)
    end

    def save_config(target_url)
      File.open(config_file, 'w') {|f| f.write({ :target_url => "#{target_url}/api/v1" }.to_yaml) }
    end

    def get_api_key(line_yaml_file)
      line_yml = YAML::load(File.read(line_yaml_file))
      line_yml['api_key'].presence
    end
    
    def set_target_uri
      if CF.api_url.blank? || CF.api_url.nil?
        if load_config
          target_url = load_config['target_url']  
          CF.api_url = "#{target_url}"
          return true
        else
          return false
        end
      end
      return false
    end
    
    def set_api_key(yaml_source)
      api_key = get_api_key(yaml_source)
      if api_key.blank?
        return false
      else
        CF.api_key = api_key unless CF.api_key.blank?
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