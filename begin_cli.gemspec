# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'begin/version'

Gem::Specification.new do |spec|
  spec.name          = 'begin_cli'
  spec.version       = Begin::VERSION
  spec.authors       = ['James Bird']
  spec.email         = ['jbrd.git@outlook.com']

  spec.summary       = 'A terminal command for beginning new projects quickly.'
  spec.homepage      = 'https://jbrd.github.io/begin'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject \
                       { |f| f.match(%r{^(docs|test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'

  spec.add_dependency 'colorize'
  spec.add_dependency 'mustache'
  spec.add_dependency 'rugged'
  spec.add_dependency 'thor'
end
