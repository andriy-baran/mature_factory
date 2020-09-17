require_relative 'lib/mature_factory/version'

Gem::Specification.new do |spec|
  spec.name          = 'mature_factory'
  spec.version       = MatureFactory::VERSION
  spec.authors       = ['Andrii Baran']
  spec.email         = ['andriy.baran.v@gmail.com']

  spec.summary       = 'A mixin for creating factory objects'
  spec.description   = 'configurable modules provide a tiny DSL for managing factory'
  spec.homepage      = 'https://github.com/andriy-baran/mature_factory'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/andriy-baran/mature_factory'
  # spec.metadata['changelog_uri'] = 'TODO: Put your gem's CHANGELOG.md URL here.'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-inflector', '~> 0.1'
  spec.add_dependency 'simple_facade', '~> 0.2'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'pry', '0.12'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_vars_helper', '~> 0.1'
end
