require 'thor'

module CF
  class CLI < Thor
    
    # include Thor::Actions
    # # debugger
    
    # # argument :file_name#, :aliases => "-n"
    # 
    desc "login", "Asks for the login information"
    def login
      # puts "Line: #{name} created"
      api_key = ask("Enter the api_key:")
      save_config(api_key)
      say("API Key saved at #{config_file}", :green)
      # @line = ::CloudFactory::Line.new(options[:name])
      # I think this might work
      # @line = ::CloudFactory::Line.new({:title => name})
    end

    private
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

  end
end