# Laneful Ruby SDK Examples

This directory contains example code demonstrating how to use the Laneful Ruby SDK.

## Quick Start

1. **Install the gem:**
   ```bash
   gem install laneful-ruby
   ```

2. **Or use Bundler:**
   ```bash
   cd examples
   bundle install
   ```

3. **Configure the example:**
   Edit `simple_example.rb` and replace the placeholder values:
   - `base_url`: Your Laneful endpoint URL
   - `auth_token`: Your authentication token
   - Email addresses: Replace with your actual email addresses

4. **Run the example:**
   ```bash
   ruby simple_example.rb
   ```

## Example Files

- **`simple_example.rb`**: Demonstrates basic email sending functionality including:
  - Simple text email
  - HTML email with tracking
  - Email with CC recipients
  - Error handling

## Configuration

Before running the examples, make sure to:

1. **Get your credentials** from your Laneful dashboard
2. **Update the configuration** in the example files:
   ```ruby
   base_url = 'https://your-endpoint.send.laneful.net'
   auth_token = 'your-auth-token'
   ```
3. **Use valid email addresses** for testing

## More Examples

For more comprehensive examples and API documentation, visit:
- [Laneful Ruby SDK Documentation](https://docs.laneful.com/ruby)
- [GitHub Repository](https://github.com/laneful/laneful-ruby)
