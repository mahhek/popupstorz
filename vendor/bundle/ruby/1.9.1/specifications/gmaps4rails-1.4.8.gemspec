# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "gmaps4rails"
  s.version = "1.4.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Benjamin Roth", "David Ruyer"]
  s.date = "2012-03-16"
  s.description = "Enables easy display of items (taken from a Rails 3 model) on a Google Maps (JS API V3), OpenLayers, Mapquest and Bing. Geocoding + Directions included. Provides much options: markers customization, infowindows, auto-adjusted zoom, polylines, polygons, circles etc... See wiki on github for full description and examples."
  s.email = ["apnea.diving.deep@gmail.com", "david.ruyer@gmail.com"]
  s.extra_rdoc_files = ["LICENSE.txt", "README.rdoc"]
  s.files = ["LICENSE.txt", "README.rdoc"]
  s.homepage = "http://github.com/apneadiving/Google-Maps-for-Rails"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Enables easy display of items (taken from a Rails 3 model) on a Google Maps (JS API V3), OpenLayers, Mapquest and Bing. Geocoding + Directions included."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
  end
end
