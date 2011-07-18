require 'ruby-debug'
require 'aruba/cucumber'
ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

Before('@slow_process') do
  @aruba_io_wait_seconds = 4
  @aruba_timeout_seconds = 4
end

Before('@too_slow_process') do
  @aruba_io_wait_seconds = 4
  @aruba_timeout_seconds = 40
end