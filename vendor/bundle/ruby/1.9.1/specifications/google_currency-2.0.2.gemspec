# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "google_currency"
  s.version = "2.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Emmons"]
  s.date = "2011-12-08"
  s.description = "GoogleCurrency extends Money::Bank::Base and gives you access to the current Google Currency exchange rates."
  s.email = ["semmons99@gmail.com"]
  s.homepage = "http://rubymoney.github.com/google_currency"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Access the Google Currency exchange rate data."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 2.0.0"])
      s.add_development_dependency(%q<yard>, [">= 0.5.8"])
      s.add_development_dependency(%q<json>, [">= 1.4.0"])
      s.add_development_dependency(%q<yajl-ruby>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<money>, ["~> 3.5"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.0.0"])
    else
      s.add_dependency(%q<rspec>, [">= 2.0.0"])
      s.add_dependency(%q<yard>, [">= 0.5.8"])
      s.add_dependency(%q<json>, [">= 1.4.0"])
      s.add_dependency(%q<yajl-ruby>, [">= 1.0.0"])
      s.add_dependency(%q<money>, ["~> 3.5"])
      s.add_dependency(%q<multi_json>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 2.0.0"])
    s.add_dependency(%q<yard>, [">= 0.5.8"])
    s.add_dependency(%q<json>, [">= 1.4.0"])
    s.add_dependency(%q<yajl-ruby>, [">= 1.0.0"])
    s.add_dependency(%q<money>, ["~> 3.5"])
    s.add_dependency(%q<multi_json>, [">= 1.0.0"])
  end
end
