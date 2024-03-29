# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'begin/version'

GEM_NAME = 'begin_cli'

SUMMARY = \
  'A terminal command for running logic-less project templates.'

DESCRIPTION = \
  'A terminal command for running logic-less project templates. ' \
  'Templates are just git repositories whose files and directories ' \
  'are copied to the working directory when run. Directory names, ' \
  'file names, and file content can contain Mustache tags - the ' \
  'values of which are prompted for in the terminal and substituted ' \
  'when the template is run.'

Gem::Specification.new do |spec|
  spec.name                  = GEM_NAME
  spec.version               = Begin::VERSION
  spec.authors               = ['James Bird']
  spec.email                 = ['jbrd.git@outlook.com']
  spec.required_ruby_version = '>= 2.4.0'

  spec.summary       = SUMMARY
  spec.description   = DESCRIPTION

  spec.homepage      = 'https://jbrd.github.io/begin'
  spec.license       = 'MIT'

  spec.files = %w[begin_cli.gemspec] + Dir['*.md', 'exe/*', 'lib/**/*.rb']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.2.33'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.49'

  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'git', '~> 1.3'
  spec.add_dependency 'mustache', '~> 1.0'
  spec.add_dependency 'thor', '~> 0.20'
end
