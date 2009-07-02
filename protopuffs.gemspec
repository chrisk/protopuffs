# encoding: UTF-8

Gem::Specification.new do |s|
  s.name = %q{protopuffs}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Kampmeier"]
  s.date = %q{2009-03-19}
  s.description = %q{A new implementation of Protocol Buffers in Ruby}
  s.email = %q{chris@kampers.net}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.files = ["LICENSE.txt", "README.rdoc", "VERSION.yml", "lib/protopuffs", "lib/protopuffs/message", "lib/protopuffs/message/base.rb", "lib/protopuffs/message/field.rb", "lib/protopuffs/message/wire_type.rb", "lib/protopuffs/parser", "lib/protopuffs/parser/parser.rb", "lib/protopuffs/parser/protocol_buffer.treetop", "lib/protopuffs.rb", "test/abstract_syntax_tree_test.rb", "test/fixtures", "test/fixtures/proto", "test/fixtures/proto/person.proto", "test/message_base_test.rb", "test/message_field_test.rb", "test/parse_tree_test.rb", "test/protopuffs_test.rb", "test/test_helper.rb", "test/text_format_test.rb", "test/wire_format_test.rb"]
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
      s.add_runtime_dependency(%q<treetop>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
    else
      s.add_dependency(%q<treetop>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<treetop>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
  end
end
