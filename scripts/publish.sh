#!/bin/bash

# Laneful Ruby SDK Publishing Script
# This script handles the complete publishing workflow to RubyGems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required environment variables are set
check_environment() {
    print_status "Checking environment variables..."
    
    if [ -z "$GEM_HOST_API_KEY" ]; then
        print_error "GEM_HOST_API_KEY environment variable is not set"
        print_status "Please set your RubyGems API key:"
        print_status "export GEM_HOST_API_KEY=your_api_key_here"
        exit 1
    fi
    
    print_success "Environment variables are set"
}

# Check if we're in the right directory
check_directory() {
    if [ ! -f "laneful-ruby.gemspec" ]; then
        print_error "laneful-ruby.gemspec not found. Please run this script from the project root."
        exit 1
    fi
    print_success "Found gemspec file"
}

# Check Ruby version
check_ruby_version() {
    print_status "Checking Ruby version..."
    ruby_version=$(ruby -v | cut -d' ' -f2)
    required_version="3.0.0"
    
    if [ "$(printf '%s\n' "$required_version" "$ruby_version" | sort -V | head -n1)" = "$required_version" ]; then
        print_success "Ruby version $ruby_version is compatible"
    else
        print_error "Ruby version $ruby_version is not compatible. Required: $required_version or higher"
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    bundle install
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies. Aborting publish."
        exit 1
    fi
}

# Run tests
run_tests() {
    print_status "Running tests..."
    bundle exec rspec
    if [ $? -eq 0 ]; then
        print_success "All tests passed"
    else
        print_error "Tests failed. Aborting publish."
        exit 1
    fi
}

# Run linting
run_lint() {
    print_status "Running linter..."
    bundle exec rubocop
    if [ $? -eq 0 ]; then
        print_success "Linting passed"
    else
        print_error "Linting failed. Aborting publish."
        exit 1
    fi
}

# Build the gem
build_gem() {
    print_status "Building gem..."
    gem build laneful-ruby.gemspec
    if [ $? -eq 0 ]; then
        print_success "Gem built successfully"
    else
        print_error "Gem build failed. Aborting publish."
        exit 1
    fi
}

# Publish to RubyGems
publish_gem() {
    print_status "Publishing to RubyGems..."
    gem push laneful-ruby-*.gem
    if [ $? -eq 0 ]; then
        print_success "Gem published successfully to RubyGems!"
    else
        print_error "Failed to publish gem to RubyGems."
        exit 1
    fi
}

# Clean up
cleanup() {
    print_status "Cleaning up..."
    rm -f laneful-ruby-*.gem
    print_success "Cleanup completed"
}

# Main execution
main() {
    print_status "Starting Laneful Ruby SDK publishing process..."
    
    check_environment
    check_directory
    check_ruby_version
    install_dependencies
    
    # Ask for confirmation
    echo
    print_warning "This will publish the gem to RubyGems. Are you sure? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_status "Publishing cancelled."
        exit 0
    fi
    
    run_tests
    run_lint
    build_gem
    publish_gem
    cleanup
    
    print_success "Publishing process completed successfully!"
    print_status "Your gem is now available on RubyGems: https://rubygems.org/gems/laneful-ruby"
}

# Handle script interruption
trap cleanup EXIT

# Run main function
main "$@"

