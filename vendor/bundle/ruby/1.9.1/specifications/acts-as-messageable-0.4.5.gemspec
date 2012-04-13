# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "acts-as-messageable"
  s.version = "0.4.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Piotr Nielacny"]
  s.date = "2012-02-08"
  s.email = "piotr.nielacny@gmail.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md"]
  s.homepage = "http://github.com/LTe/acts-as-messageable"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Make user messageable!;-)"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<ancestry>, ["~> 1.2.4"])
      s.add_runtime_dependency(%q<railties>, [">= 3.0.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.7.0"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 3.0.0"])
      s.add_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_dependency(%q<ancestry>, ["~> 1.2.4"])
      s.add_dependency(%q<railties>, [">= 3.0.0"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.7.0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 3.0.0"])
    s.add_dependency(%q<activesupport>, [">= 3.0.0"])
    s.add_dependency(%q<ancestry>, ["~> 1.2.4"])
    s.add_dependency(%q<railties>, [">= 3.0.0"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.7.0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
  end
end
