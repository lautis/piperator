# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'piperator/version'

Gem::Specification.new do |spec|
  spec.name = 'piperator'
  spec.version = Piperator::VERSION
  spec.authors = ['Ville Lautanala']
  spec.email = ['lautis@gmail.com']

  spec.summary = 'Composable pipelines for streaming large collections'
  spec.description = 'Pipelines for streaming large collections with composition inspired by Elixir pipes.'
  spec.homepage = 'https://github.com/lautis/piperator'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
