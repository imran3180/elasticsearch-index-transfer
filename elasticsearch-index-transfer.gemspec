
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "elasticsearch/index/transfer/version"

Gem::Specification.new do |spec|
  spec.name          = "elasticsearch-index-transfer"
  spec.version       = Elasticsearch::Index::Transfer::VERSION
  spec.authors       = ["Imran"]
  spec.email         = ["imranjannatiitkgp@gmail.com"]

  spec.summary       = "Ruby gem for transferring elasticsearch index from one source to another source"
  spec.description   = "Ruby gem for transferring elasticsearch index from one source to another source"
  spec.homepage      = "https://github.com/imran3180/elasticsearch-index-transfer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "elasticsearch"
  spec.add_development_dependency "aws-sdk-s3"
  spec.add_development_dependency "rspec", "~> 3.2"
end
