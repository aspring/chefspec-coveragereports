# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chefspec/coveragereports/version'

Gem::Specification.new do |spec|
  spec.name          = 'chefspec-coveragereports'
  spec.version       = ChefSpec::CoverageReports::Version::STRING.dup
  spec.authors       = ['Anthony Spring']
  spec.email         = ['tony@porkchopsandpaintchips.com']
  spec.summary       = 'ChefSpec Coverage Reports'
  spec.description   = 'ChefSpec Coverage Reports'
  spec.homepage      = 'https://github.com/aspring/chefspec-coveragereports'
  spec.license       = 'MIT'

  spec.cert_chain    = ['certs/aspring.pem']
  spec.signing_key   = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

  spec.files         = Dir['{bin}/**/*', '{lib}/**/*.rb', '{templates}/**/*.erb', 'LICENSE.txt', '*.md']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'chefspec', '>= 4.0'

  spec.add_development_dependency 'bundler',    '~> 1.7'
  spec.add_development_dependency 'rake',       '~> 10.0'
end
