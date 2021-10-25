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

group :development, :test do
  gem 'aasm' # state-machine management
  gem 'paper_trail' # Track object changes
  gem 'rdf', '~> 3.1.15'
  gem 'redis', '~> 4.1'
end

group :test do
  gem 'bcrypt', '>= 3.1.13'
  gem 'kaminari' # Pagination
  gem 'rdf-n3', '~> 3.1.2'
  gem 'rdf-vocab', '~> 3.1.14'
end
