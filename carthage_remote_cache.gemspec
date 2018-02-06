Gem::Specification.new do |spec|
  spec.name          = "carthage_remote_cache"
  spec.version       = "0.0.2"

  spec.summary       = %q{Centralized cache to serve carthage frameworks. Useful for distributed CI setup with several build machines.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/kayak/carthage_remote_cache"
  spec.license       = "Apache-2.0"
  spec.authors       = ["Juraj Blahunka"]
  spec.email         = ["jblahunka@kayak.com"]

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|example)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rerun"

  spec.add_runtime_dependency "concurrent-ruby", "~> 1.0.5"
  spec.add_runtime_dependency "rack", "~> 2.0.4"
  spec.add_runtime_dependency "rest-client", "~> 2.0.2"
  spec.add_runtime_dependency "sinatra", "~> 2.0.0"
end
