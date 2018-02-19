lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keyrod/version'

Gem::Specification.new do |spec|
  spec.name          = 'keyrod'
  spec.version       = Keyrod::VERSION
  spec.summary       = 'Keyrod CLI'
  spec.description   = 'CLI for authenticating OIDC clients in EGI Federated Cloud'
  spec.authors       = ['Cuong Duong Tuan']
  spec.email         = 'cduongt@cesnet.cz'
  spec.files         = Dir['lib/**/*.rb', 'config/*.yml']
  spec.require_paths = ['lib']
  spec.executables   = ['keyrod']
  spec.homepage      = 'https://github.com/cduongt/keyrod'
  spec.license       = 'Apache-2.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.52'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.22'

  spec.add_runtime_dependency 'settingslogic', '~> 2.0'
  spec.add_runtime_dependency 'thor', '~> 0.20'

  spec.required_ruby_version = '>= 2.2.0'
end
