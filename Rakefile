require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run all specs across all supported Rails gem versions.'
task :default => :spec

desc 'Run all specs across all supported Rails gem versions.'
task :spec do
  %w(2.1.2 2.2.2 2.3.2).each do |rails_gem_version|
    puts "*** GEM VERSION #{rails_gem_version} ***"
    cmd = "cd test_rails_app && RAILS_GEM_VERSION=#{rails_gem_version} rake"
    puts cmd
    puts `#{cmd}`
    puts
    puts
  end
end

desc 'Generate documentation for the admin_assistant plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'AdminAssistant'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
