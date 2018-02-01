Gem::Specification.new do |spec|
  spec.name          = "carthage_remote_cache"
  spec.version       = "0.0.1"

  spec.summary       = %q{Centralized cache to serve carthage frameworks. Useful for distributed CI setup, e.g. Bamboo with several build machines.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/kayak/carthage_remote_cache"
  spec.license       = "Apache-2.0"
  spec.authors       = ["Juraj Blahunka"]
  spec.email         = ["jblahunka@kayak.com"]

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "rerun"
  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "sinatra"
end
