# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "geokit"
  s.version = "1.6.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Cox, Andre Lewis & Bill Eisenhauer"]
  s.date = "2012-01-23"
  s.description = "Geokit provides geocoding and distance calculation in an easy-to-use API"
  s.email = ["james+geokit@imaj.es"]
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["README.markdown"]
  s.homepage = "https://github.com/imajes/geokit-gem"
  s.rdoc_options = ["--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "geokit"
  s.rubygems_version = "1.8.15"
  s.summary = "Geokit: encoding and distance calculation gem"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
