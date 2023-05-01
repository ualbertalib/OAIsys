source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in oaisys.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

# RDF stuff
gem 'acts_as_rdfable', github: 'ualbertalib/acts_as_rdfable', tag: 'v0.2.4'
gem 'builder_deferred_tagging', github: 'ualbertalib/builder_deferred_tagging', tag: 'v0.01'

gem 'builder', '~> 3.0'
gem 'nanoid'
gem 'pg'
gem 'rails', '>= 5.2.3', '< 7'
gem 'redis', '~> 4.1'

group :development, :test do
  gem 'pry'
  gem 'rubocop', '~> 1.7'
  gem 'rubocop-performance'
  gem 'rubocop-rails', '~> 2.19', '>= 2.19.1'
end
