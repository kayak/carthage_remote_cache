lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "version"

Gem::Specification.new do |spec|
  spec.name = "carthage_remote_cache"
  spec.version = VERSION

  spec.summary = %q{Centralized cache to serve carthage frameworks. Useful for distributed CI setup with several build machines.}
  spec.description = spec.summary
  spec.homepage = "https://github.com/kayak/carthage_remote_cache"
  spec.license = "Apache-2.0"
  spec.authors = ["Juraj Blahunka"]
  spec.email = ["jblahunka@kayak.com"]

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|example|integrations)/})
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "guard", "~> 2.14.2"
  spec.add_development_dependency "guard-test", "~> 2.0.8"
  spec.add_development_dependency "mocha", "~> 1.3.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rerun"
  spec.add_development_dependency "rufo"
  spec.add_development_dependency "test-unit", "~> 3.2.7"

  spec.add_runtime_dependency "concurrent-ruby", "~> 1.0.5"
  spec.add_runtime_dependency "rack", ">= 2.0.6", "< 3.2.0"
  spec.add_runtime_dependency "rest-client", "~> 2.0.2"
  spec.add_runtime_dependency "sinatra", ">= 2.0.4", "< 3.1.0"
end
