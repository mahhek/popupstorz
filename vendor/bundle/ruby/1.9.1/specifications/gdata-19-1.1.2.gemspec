# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "gdata-19"
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["This is the gdata ruby gem. Minor updates for Ruby 1.9."]
  s.date = "2011-04-28"
  s.description = "A Ruby gem designed to assist Ruby developers in working with Google Data APIs"
  s.email = ["bridgeutopia@gmail.com"]
  s.homepage = ""
  s.require_paths = ["lib"]
  s.rubyforge_project = "gdata"
  s.rubygems_version = "1.8.15"
  s.summary = "A Ruby gem designed to assist Ruby developers in working with Google Data APIs"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<test-unit>, [">= 0"])
    else
      s.add_dependency(%q<test-unit>, [">= 0"])
    end
  else
    s.add_dependency(%q<test-unit>, [">= 0"])
  end
end
