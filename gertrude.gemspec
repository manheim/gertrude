# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gertrude/version'

Gem::Specification.new do |spec|
  spec.name          = "gertrude"
  spec.version       = Gertrude::VERSION
  spec.authors       = ["Wallace Harwood", "Jarod Adair", "Umair Chagani"]
  spec.email         = ["wallace.harwood@manheim.com", "jarod.adair@manheim.com", "umair.chagani@manheim.com"]

  spec.summary       = %q{Librarian to manage your things for you.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'pry'
  spec.add_runtime_dependency 'bundler', "~> 1.11"
  spec.add_runtime_dependency 'sinatra'
  spec.add_runtime_dependency 'test-helpers'
  spec.add_runtime_dependency 'json_pure'
  spec.add_runtime_dependency 'rack-test'
end

