#!/bin/bash

# Laneful Ruby SDK Examples - Docker Runner
# This script helps you run the Ruby examples using Docker

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

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    print_status "Please copy env.example to .env and fill in your credentials:"
    echo "  cp env.example .env"
    echo "  nano .env"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Function to build the Docker image
build_image() {
    print_status "Building Docker image..."
    docker build -f examples/Dockerfile -t laneful-ruby-examples:latest ..
    print_success "Docker image built successfully!"
}

# Function to run an example
run_example() {
    local example_name=$1
    print_status "Running example: $example_name"
    docker run --rm --env-file .env laneful-ruby-examples:latest "$example_name"
}

# Function to show available examples
show_examples() {
    echo "Available examples:"
    echo "  BasicEmailExample"
    echo "  HTMLEmailWithTrackingExample"
    echo "  TemplateEmailExample"
    echo "  AttachmentEmailExample"
    echo "  MultipleRecipientsExample"
    echo "  ScheduledEmailExample"
    echo "  BatchEmailExample"
    echo "  WebhookHandlerExample"
    echo "  ErrorHandlingExample"
    echo "  ComprehensiveExample"
}

# Function to run all examples
run_all_examples() {
    local examples=(
        "BasicEmailExample"
        "HTMLEmailWithTrackingExample"
        "TemplateEmailExample"
        "AttachmentEmailExample"
        "MultipleRecipientsExample"
        "ScheduledEmailExample"
        "BatchEmailExample"
        "WebhookHandlerExample"
        "ErrorHandlingExample"
    )
    
    print_status "Running all examples..."
    for example in "${examples[@]}"; do
        echo ""
        print_status "=== Running $example ==="
        run_example "$example"
        echo ""
    done
    
    print_status "=== Running ComprehensiveExample ==="
    run_example "ComprehensiveExample"
    
    print_success "All examples completed!"
}

# Main script logic
case "${1:-}" in
    "build")
        build_image
        ;;
    "list")
        show_examples
        ;;
    "all")
        build_image
        run_all_examples
        ;;
    "webhook")
        print_status "Starting webhook handler..."
        docker-compose up webhook-handler
        ;;
    "")
        print_error "No command specified!"
        echo ""
        echo "Usage: $0 <command> [example_name]"
        echo ""
        echo "Commands:"
        echo "  build                    - Build the Docker image"
        echo "  list                     - Show available examples"
        echo "  all                      - Run all examples"
        echo "  webhook                  - Start webhook handler"
        echo "  <example_name>           - Run specific example"
        echo ""
        show_examples
        ;;
    *)
        # Check if it's a valid example name
        if docker run --rm --env-file .env laneful-ruby-examples:latest "$1" 2>/dev/null; then
            print_success "Example '$1' completed successfully!"
        else
            print_error "Unknown example: $1"
            echo ""
            show_examples
            exit 1
        fi
        ;;
esac
