module Cf
  module Config
    def config_file
      File.join(find_home, '.cflogin')
    end

    def load_config
      YAML::load(File.read(config_file))
    end

    def save_config(api_key)
      File.open(config_file, 'w') {|f| f.write({ :api_key => api_key }.to_yaml) }
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