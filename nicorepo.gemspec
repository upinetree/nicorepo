lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nicorepo/version'

Gem::Specification.new do |spec|
  spec.name          = "nicorepo"
  spec.version       = Nicorepo::VERSION
  spec.authors       = ["upinetree"]
  spec.email         = ["essequake@gmail.com"]
  spec.summary       = %q{Nicorepo scraper}
  spec.description   = %q{Nicorepo scraper}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "mechanize"
  spec.add_dependency "launchy"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

