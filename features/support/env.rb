require 'ruby-debug'
require 'aruba/cucumber'
ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

Before('@slow_process') do
  @aruba_io_wait_seconds = 2
end