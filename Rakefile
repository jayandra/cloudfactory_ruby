require 'bundler'
require 'rubygems'
require 'rake'  
require 'rdoc/rdoc'
Bundler::GemHelper.install_tasks

begin
  task :default => :build
  require 'rake/rdoctask'
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options << '--fmt' << 'darkfish'
    rdoc.title = "cloudfactory"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
end