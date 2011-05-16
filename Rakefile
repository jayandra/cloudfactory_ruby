require 'bundler'
require 'rubygems'
require 'rake'  
require 'rdoc/rdoc'
Bundler::GemHelper.install_tasks

begin
  task :default => :build
  require 'rake/rdoctask'
  
  html_dir = 'doc/rdoc'
  library = 'CloudFactory'
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = "#{html_dir}"
    rdoc.options << '--fmt' << 'darkfish'
    rdoc.title = "#{library} Ruby Gem API Documentation"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
  
  # Setting up the rake task to generate and upload the documentation to remote
  rdoc_upload_path = "/var/www"
  user = "vagrant"
  remote_host = "33.33.33.10"

  desc 'Upload documentation to Dev CloudFactory'
  task 'upload-docs' => ['rdoc'] do
    sh "scp -r #{html_dir}/* #{user}@#{remote_host}:#{rdoc_upload_path}/cf-doc"
  end

  # website_dir = 'site'
  # desc 'Update project website to RubyForge.'
  # task 'upload-site' do
  #   sh "scp -r #{website_dir}/* " +
  #   "#{rubyforge_user}@rubyforge.org:/var/www/gforge-projects/project/"
  # end

  # desc 'Update API docs and project website to RubyForge.'
  # task 'publish' => ['upload-docs', 'upload-site']
end