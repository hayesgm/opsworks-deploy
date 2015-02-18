# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opsworks/deploy/version'

Gem::Specification.new do |spec|
  spec.name          = "opsworks-deploy"
  spec.version       = Opsworks::Deploy::VERSION
  spec.authors       = ["Geoff Hayes"]
  spec.email         = ["hayesgm@gmail.com"]
  spec.description   = %q{Quick and easy rake task for deploying to AWS OpsWorks}
  spec.summary       = %q{A quick rake task that will deploy to AWS OpsWorks.  This can be added as a post-step in Continuous Integration.  `rake opsworks:deploy`}
  spec.homepage      = "https://github.com/hayesgm/opsworks-deploy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'aws-sdk', '~> 1.62'
  spec.add_runtime_dependency 'json'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'aws-sdk'
end
