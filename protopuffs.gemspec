# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{protopuffs}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Kampmeier"]
  s.date = %q{2009-01-23}
  s.description = %q{A new implementation of Protocol Buffers in Ruby, based on the original ruby_protobuf library.}
  s.email = %q{chris@kampers.net}
  s.files = ["LICENSE.txt", "README.rdoc", "VERSION.yml", "lib/protopuffs.rb", "test/protopuffs_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/chrisk/protopuffs}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Sex, drugs, and protocol buffers}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
