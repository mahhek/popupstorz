# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require 'rubygems'
require "gdata/version"
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/gempackagetask'

task :default => [:test]

task :test do
  ruby "test/ts_gdata.rb"
end

task :prepdoc do
  all_doc_files = FileList.new('doc/**/*')
  all_doc_files.each do |file|
    system "hg add #{file}"
  end
end

task :doc do
  system "rdoc -U --title 'gdata module documentation' -m README README lib/"
end



Gem::Specification.new do |s|
  s.name        = "gdata-19"
  s.version     = Gdata::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["This is the gdata ruby gem. Minor updates for Ruby 1.9."]
  s.email       = ["bridgeutopia@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A Ruby gem designed to assist Ruby developers in working with Google Data APIs}
  s.description = %q{A Ruby gem designed to assist Ruby developers in working with Google Data APIs}
  s.add_development_dependency "test-unit"
  s.rubyforge_project = "gdata"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
