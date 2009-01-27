require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "protopuffs"
    s.summary = %Q{Sex, drugs, and protocol buffers}
    s.email = "chris@kampers.net"
    s.homepage = "http://github.com/chrisk/protopuffs"
    s.description = "A new implementation of Protocol Buffers in Ruby"
    s.authors = ["Chris Kampmeier"]
    s.add_dependency "treetop"
    s.add_development_dependency "mocha"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Protopuffs'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('LICENSE*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rcov::RcovTask.new do |t|
  t.libs << 'test'
  t.rcov_opts << '--exclude "gems/*"'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :default => :test
