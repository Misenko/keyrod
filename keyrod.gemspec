Gem::Specification.new do |spec|
  spec.name          = 'keyrod'
  spec.version       = '0.0.0'
  spec.summary       = 'Keyrod CLI'
  spec.description   = 'CLI for authenticating OIDC clients in EGI Federated Cloud'
  spec.authors       = ['Cuong Duong Tuan']
  spec.email         = 'cduongt@cesnet.cz'
  spec.files         = Dir['lib/**/*.rb', 'config/*.yml']
  spec.require_paths = ['lib']
  spec.executables   = ['keyrod']
  spec.homepage      = 'https://github.com/cduongt/keyrod'
  spec.license       = 'Apache License, Version 2.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rubocop', '~> 0.48'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.15'
  spec.add_runtime_dependency 'settingslogic', '~> 2.0'
  spec.add_runtime_dependency 'thor', '~> 0.19'
end
