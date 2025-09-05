# Laneful Ruby SDK Makefile

.PHONY: help test lint build publish clean install setup

# Default target
help:
	@echo "Available commands:"
	@echo "  setup    - Install dependencies"
	@echo "  test     - Run tests"
	@echo "  lint     - Run code linting"
	@echo "  build    - Build the gem"
	@echo "  publish  - Publish to RubyGems (requires RUBYGEMS_API_KEY)"
	@echo "  install  - Install gem locally"
	@echo "  clean    - Clean up built gems"

# Install dependencies
setup:
	bundle install

# Run tests
test:
	bundle exec rspec

# Run linting
lint:
	bundle exec rubocop

# Build gem
build:
	gem build laneful-ruby.gemspec

# Publish to RubyGems
publish:
	@if [ -z "$$GEM_HOST_API_KEY" ]; then \
		echo "Error: GEM_HOST_API_KEY environment variable is not set"; \
		echo "Please set your RubyGems API key: export GEM_HOST_API_KEY=your_api_key_here"; \
		exit 1; \
	fi
	./scripts/publish.sh

# Install gem locally
install:
	gem build laneful-ruby.gemspec
	gem install laneful-ruby-*.gem

# Clean up
clean:
	rm -f laneful-ruby-*.gem

