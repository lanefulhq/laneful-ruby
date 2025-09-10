# Laneful Ruby SDK Examples

This directory contains comprehensive examples demonstrating how to use the Laneful Ruby SDK for sending emails and handling webhooks.

## Quick Start with Docker

The easiest way to run the examples is using Docker:

### 1. Set up environment variables

```bash
# Copy the example environment file
cp env.example .env

# Edit .env with your actual Laneful credentials
nano .env
```

### 2. Build and run examples

```bash
# Build the Docker image
docker build -f examples/Dockerfile -t laneful-ruby-examples:latest ..

# Run a specific example
docker run --rm --env-file .env laneful-ruby-examples:latest BasicEmailExample
```

## Available Examples

| Example | Description | Docker Command |
|---------|-------------|----------------|
| **BasicEmailExample** | Send a simple text email | `docker run --rm --env-file .env laneful-ruby-examples:latest BasicEmailExample` |
| **HTMLEmailWithTrackingExample** | Send HTML email with tracking | `docker run --rm --env-file .env laneful-ruby-examples:latest HTMLEmailWithTrackingExample` |
| **TemplateEmailExample** | Send email using a template | `docker run --rm --env-file .env laneful-ruby-examples:latest TemplateEmailExample` |
| **AttachmentEmailExample** | Send email with attachment | `docker run --rm --env-file .env laneful-ruby-examples:latest AttachmentEmailExample` |
| **MultipleRecipientsExample** | Send email to multiple recipients | `docker run --rm --env-file .env laneful-ruby-examples:latest MultipleRecipientsExample` |
| **ScheduledEmailExample** | Send scheduled email | `docker run --rm --env-file .env laneful-ruby-examples:latest ScheduledEmailExample` |
| **BatchEmailExample** | Send multiple emails in batch | `docker run --rm --env-file .env laneful-ruby-examples:latest BatchEmailExample` |
| **WebhookHandlerExample** | Demonstrate webhook handling | `docker run --rm --env-file .env laneful-ruby-examples:latest WebhookHandlerExample` |
| **ErrorHandlingExample** | Demonstrate error handling | `docker run --rm --env-file .env laneful-ruby-examples:latest ErrorHandlingExample` |
| **ComprehensiveExample** | Run all examples together | `docker run --rm --env-file .env laneful-ruby-examples:latest ComprehensiveExample` |

## Local Development Setup

If you prefer to run the examples locally without Docker:

### 1. Install dependencies

```bash
# Install the SDK gem
gem install laneful-ruby

# Install example dependencies
bundle install
```

### 2. Set up environment variables

```bash
export LANEFUL_BASE_URL="https://your-subdomain.z1.send.dev.laneful.net"
export LANEFUL_AUTH_TOKEN="priv-YourAuthTokenHere"
export LANEFUL_FROM_EMAIL="sender@yourdomain.com"
export LANEFUL_TO_EMAILS="recipient1@example.com,recipient2@example.com"
export LANEFUL_TEMPLATE_ID="your-template-id"
export LANEFUL_WEBHOOK_SECRET="your-webhook-secret"
export LANEFUL_WEBHOOK_URL="https://your-domain.com/webhook"
```

### 3. Run examples

```bash
# Run a specific example
ruby src/basic_email_example.rb

# Or run all examples
ruby src/comprehensive_example.rb
```

## Environment Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `LANEFUL_BASE_URL` | Your Laneful API endpoint | `https://your-subdomain.z1.send.dev.laneful.net` |
| `LANEFUL_AUTH_TOKEN` | Your Laneful API token | `priv-YourAuthTokenHere` |
| `LANEFUL_FROM_EMAIL` | Verified sender email | `sender@yourdomain.com` |
| `LANEFUL_TO_EMAILS` | Comma-separated recipient emails | `user1@example.com,user2@example.com` |

### Optional Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `LANEFUL_TEMPLATE_ID` | Template ID for template examples | `welcome-template` |
| `LANEFUL_WEBHOOK_SECRET` | Webhook secret for webhook examples | `your-webhook-secret` |
| `LANEFUL_WEBHOOK_URL` | Webhook URL for webhook examples | `https://your-domain.com/webhook` |

## Example Features

### 📧 Email Sending
- **Basic Email**: Simple text email
- **HTML Email**: Rich HTML content with tracking
- **Template Email**: Use pre-designed templates
- **Attachments**: Send files with emails
- **Multiple Recipients**: TO, CC, BCC support
- **Scheduled Email**: Send emails at specific times
- **Batch Sending**: Send multiple emails efficiently

### 🔗 Webhook Handling
- **Signature Verification**: HMAC-SHA256 verification
- **Payload Parsing**: JSON structure validation
- **Event Processing**: Handle all webhook event types
- **Batch Mode**: Support for multiple events
- **Error Handling**: Comprehensive error management

### 🛡️ Error Handling
- **Validation Errors**: Input validation failures
- **API Errors**: Server-side error responses
- **HTTP Errors**: Network and connection issues
- **Comprehensive Logging**: Detailed error information

## Docker Troubleshooting

### Build Issues
```bash
# Clean build (no cache)
docker build --no-cache -f examples/Dockerfile -t laneful-ruby-examples:latest ..

# Check build logs
docker build -f examples/Dockerfile -t laneful-ruby-examples:latest .. 2>&1 | tee build.log
```

### Runtime Issues
```bash
# Check environment variables
docker run --rm --env-file .env laneful-ruby-examples:latest

# Run with debug output
docker run --rm --env-file .env -it laneful-ruby-examples:latest /bin/bash
```

### Webhook Testing
```bash
# Start webhook handler
docker-compose up webhook-handler

# Test webhook endpoint
curl -X POST http://localhost:4567/webhook \
  -H "Content-Type: application/json" \
  -H "x-webhook-signature: sha256=your-signature" \
  -d '{"event":"delivery","email":"test@example.com"}'
```

## Examples Based on Documentation

These examples are based on the official Laneful Ruby SDK documentation and demonstrate:

- ✅ All API methods and features
- ✅ Proper error handling patterns
- ✅ Environment variable usage for security
- ✅ Production-ready code patterns
- ✅ Comprehensive webhook handling
- ✅ Modern Ruby best practices

## Support

For questions or issues:
- Check the [Laneful Ruby SDK documentation](https://docs.laneful.com/ruby-sdk)
- Review the [GitHub repository](https://github.com/lanefulhq/laneful-ruby)
- Contact support through your Laneful dashboard
