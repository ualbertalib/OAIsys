$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'oaisys/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'oaisys'
  spec.version     = Oaisys::VERSION
  spec.authors     = ['ConnorSheremeta']
  spec.email       = ['sheremet@ualberta.ca']
  spec.homepage    = 'https://github.com/ualbertalib/oaisys'
  spec.summary     = 'OAI-PMH engine'
  spec.description = "Jupiter's engine for Open Archives Initiative Protocol for Metadata Harvesting"
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 2.6.6'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'builder', '~> 3.0'
  spec.add_dependency 'nanoid'
  spec.add_dependency 'rails', '>= 5.2.3', '< 7'
  spec.add_dependency 'redis', '~> 4.1'

  spec.add_dependency 'pg'
  spec.add_dependency 'rubocop'
  spec.add_dependency 'rubocop-performance'
  spec.add_dependency 'rubocop-rails'

  spec.add_development_dependency 'pry'
end
