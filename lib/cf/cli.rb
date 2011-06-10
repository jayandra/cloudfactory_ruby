require 'thor'
require 'cloud_factory/line'

module CF
  class CLI < Thor

    desc "create NAME", "Creates a new line with the name NAME"
    method_option :name, :aliases => "-n"
    def create(name)
      # FIXME: the commented code should have worked but its not
      puts "Line: #{name} created"
      # @line = ::CloudFactory::Line.new(options[:name])
    end

  end
end