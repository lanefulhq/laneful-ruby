# Laneful Ruby SDK

A modern Ruby client library for the Laneful email API with support for sending emails, templates, tracking, and webhooks.

## Requirements

- Ruby 3.0 or higher
- Bundler (for dependency management)

## Installation

### Using Bundler

Add the following to your `Gemfile`:

```ruby
gem 'laneful-ruby'
```

Then run:

```bash
bundle install
```

### Manual Installation

```bash
git clone https://github.com/lanefulhq/laneful-ruby.git
cd laneful-ruby
bundle install
bundle exec rake install
```

## Quick Start

```ruby
require 'laneful'

# Create client
client = Laneful::Client.new(
  'https://your-endpoint.send.laneful.net',
  'your-auth-token'
)

# Create email
email = Laneful::Email::Builder.new
  .from(Laneful::Address.new('sender@example.com', 'Your Name'))
  .to(Laneful::Address.new('recipient@example.com', 'Recipient Name'))
  .subject('Hello from Laneful Ruby SDK!')
  .text_content('This is a simple test email.')
  .build

# Send email
response = client.send_email(email)
puts "Email sent successfully!"
```

## Features

- Send single or multiple emails
- Plain text and HTML content
- Email templates with dynamic data
- File attachments
- Email tracking (opens, clicks, unsubscribes)
- Custom headers and reply-to addresses
- Scheduled sending
- Webhook signature verification
- Comprehensive error handling
- Modern Ruby 3.0+ features

## Examples

### Simple Text Email

```ruby
email = Laneful::Email::Builder.new
  .from(Laneful::Address.new('sender@example.com'))
  .to(Laneful::Address.new('user@example.com'))
  .subject('Simple Email')
  .text_content('This is a simple text email.')
  .build

response = client.send_email(email)
```

### HTML Email with Tracking

```ruby
tracking = Laneful::TrackingSettings.new(opens: true, clicks: true, unsubscribes: false)

email = Laneful::Email::Builder.new
  .from(Laneful::Address.new('sender@example.com'))
  .to(Laneful::Address.new('user@example.com'))
  .subject('HTML Email with Tracking')
  .html_content('<h1>Welcome!</h1><p>This is an <strong>HTML email</strong> with tracking enabled.</p>')
  .text_content('Welcome! This is an HTML email with tracking enabled.')
  .tracking(tracking)
  .build

response = client.send_email(email)
```

### Template Email

```ruby
email = Laneful::Email::Builder.new
  .from(Laneful::Address.new('sender@example.com'))
  .to(Laneful::Address.new('user@example.com'))
  .template_id('welcome-template')
  .template_data({
    'name' => 'John Doe',
    'company' => 'Acme Corp'
  })
  .build

response = client.send_email(email)
```

### Email with Attachments

```ruby
# Create attachment from file
attachment = Laneful::Attachment.from_file('/path/to/document.pdf')

email = Laneful::Email::Builder.new
  .from(Laneful::Address.new('sender@example.com'))
  .to(Laneful::Address.new('user@example.com'))
  .subject('Document Attached')
  .text_content('Please find the document attached.')
  .attachment(attachment)
  .build

response = client.send_email(email)
```

### Multiple Recipients

```ruby
email = Laneful::Email::Builder.new
  .from(Laneful::Address.new('sender@example.com'))
  .to(Laneful::Address.new('user1@example.com'))
  .to(Laneful::Address.new('user2@example.com', 'User Two'))
  .cc(Laneful::Address.new('cc@example.com'))
  .bcc(Laneful::Address.new('bcc@example.com'))
  .subject('Multiple Recipients')
  .text_content('This email has multiple recipients.')
  .build

response = client.send_email(email)
```

### Scheduled Email

```ruby
# Schedule for 24 hours from now
send_time = Time.now.to_i + (24 * 60 * 60)

email = Laneful::Email::Builder.new
  .from(Laneful::Address.new('sender@example.com'))
  .to(Laneful::Address.new('user@example.com'))
  .subject('Scheduled Email')
  .text_content('This email was scheduled.')
  .send_time(send_time)
  .build

response = client.send_email(email)
```

### Multiple Emails

```ruby
emails = [
  Laneful::Email::Builder.new
    .from(Laneful::Address.new('sender@example.com'))
    .to(Laneful::Address.new('user1@example.com'))
    .subject('Email 1')
    .text_content('First email content.')
    .build,
  Laneful::Email::Builder.new
    .from(Laneful::Address.new('sender@example.com'))
    .to(Laneful::Address.new('user2@example.com'))
    .subject('Email 2')
    .text_content('Second email content.')
    .build
]

response = client.send_emails(emails)
```

### Custom Timeout

```ruby
client = Laneful::Client.new(
  'https://your-endpoint.send.laneful.net',
  'your-auth-token',
  timeout: 60  # 60 second timeout
)
```

## Webhook Verification

```ruby
# In your webhook handler
payload = request.body.read
signature = request.headers['X-Laneful-Signature']
secret = 'your-webhook-secret'

if Laneful::WebhookVerifier.verify_signature(secret, payload, signature)
  # Process webhook data
  data = JSON.parse(payload)
  # Handle webhook event
else
  # Invalid signature
  head :unauthorized
end
```

## Error Handling

```ruby
begin
  response = client.send_email(email)
  puts "Email sent successfully"
rescue Laneful::ValidationException => e
  puts "Validation error: #{e.message}"
rescue Laneful::ApiException => e
  puts "API error: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Error message: #{e.error_message}"
rescue Laneful::HttpException => e
  puts "HTTP error: #{e.message}"
  puts "Status code: #{e.status_code}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
end
```

## API Reference

### Laneful::Client

#### Constructor

```ruby
Laneful::Client.new(base_url, auth_token, timeout: 30)
```

- `base_url` - The base URL of the Laneful API
- `auth_token` - The authentication token
- `timeout` - Request timeout in seconds (optional, default: 30)

#### Methods

- `send_email(email)` - Sends a single email
- `send_emails(emails)` - Sends multiple emails

### Laneful::Email::Builder

#### Required Fields

- `from(address)` - Sender address

#### Optional Fields

- `to(address)` - Recipient addresses
- `cc(address)` - CC addresses
- `bcc(address)` - BCC addresses
- `subject(subject)` - Email subject
- `text_content(content)` - Plain text content
- `html_content(content)` - HTML content
- `template_id(id)` - Template ID
- `template_data(data)` - Template data
- `attachment(attachment)` - File attachments
- `headers(headers)` - Custom headers
- `reply_to(address)` - Reply-to address
- `send_time(time)` - Scheduled send time (Unix timestamp)
- `webhook_data(data)` - Webhook data
- `tag(tag)` - Email tag
- `tracking(tracking)` - Tracking settings

### Laneful::Address

```ruby
Laneful::Address.new(email, name = nil)
```

- `email` - The email address (required)
- `name` - The display name (optional)

### Laneful::Attachment

```ruby
# From file
Laneful::Attachment.from_file(file_path)

# From raw data
Laneful::Attachment.new(filename, content_type, content)
```

### Laneful::TrackingSettings

```ruby
Laneful::TrackingSettings.new(opens: false, clicks: false, unsubscribes: false)
```

### Laneful::WebhookVerifier

```ruby
Laneful::WebhookVerifier.verify_signature(secret, payload, signature)
```

## Exception Types

- `Laneful::ValidationException` - Thrown when input validation fails
- `Laneful::ApiException` - Thrown when the API returns an error response
- `Laneful::HttpException` - Thrown when HTTP communication fails
- `Laneful::LanefulException` - Base exception class for all SDK exceptions

## Development

### Running Tests

```bash
bundle exec rspec
```

### Code Quality

```bash
bundle exec rubocop
```

### Documentation

```bash
bundle exec yard doc
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

