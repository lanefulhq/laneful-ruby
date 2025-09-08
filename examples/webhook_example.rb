#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'laneful'

# Configuration
WEBHOOK_SECRET = ENV['LANEFUL_WEBHOOK_SECRET'] || 'your-webhook-secret-here'

# Enable JSON parsing
set :port, ENV['PORT'] || 4567

# Complete webhook verification and processing workflow
# following the documentation exactly
def handle_webhook
  # Step 1: Get raw payload
  payload = request.body.read
  raise StandardError, 'Empty payload received' if payload.empty?

  # Step 2: Extract signature from headers (as documented)
  signature = Laneful::WebhookVerifier.extract_signature_from_headers(request.env)
  raise StandardError, 'Missing webhook signature header' if signature.nil?

  # Step 3: Verify signature (supports sha256= prefix as documented)
  unless Laneful::WebhookVerifier.verify_signature(WEBHOOK_SECRET, payload, signature)
    raise StandardError, 'Invalid webhook signature'
  end

  # Step 4: Parse and validate payload structure
  webhook_data = Laneful::WebhookVerifier.parse_webhook_payload(payload)

  # Step 5: Process events (handles both batch and single event formats)
  processed_count = 0
  webhook_data[:events].each do |event|
    process_webhook_event(event)
    processed_count += 1
  end

  # Log successful processing
  puts "Successfully processed #{processed_count} webhook event(s) in #{webhook_data[:is_batch] ? 'batch' : 'single'} mode"

  # Return success response
  status 200
  content_type :json
  {
    status: 'success',
    processed: processed_count,
    mode: webhook_data[:is_batch] ? 'batch' : 'single'
  }.to_json
rescue ArgumentError => e
  # Payload validation error
  puts "Webhook payload validation error: #{e.message}"
  status 400
  content_type :json
  { error: "Invalid payload: #{e.message}" }.to_json
rescue StandardError => e
  # Other errors (signature, missing data, etc.)
  puts "Webhook processing error: #{e.message}"
  status 401
  content_type :json
  { error: e.message }.to_json
end

# Process individual webhook events according to documentation
def process_webhook_event(event)
  event_type = event['event']
  email = event['email']
  message_id = event['message_id']
  event['timestamp']

  # Log basic event info
  puts "Processing #{event_type} event for #{email} (Message ID: #{message_id})"

  # Process based on event type (all types from documentation)
  case event_type
  when 'delivery'
    handle_delivery_event(event)
  when 'open'
    handle_open_event(event)
  when 'click'
    handle_click_event(event)
  when 'bounce'
    handle_bounce_event(event)
  when 'drop'
    handle_drop_event(event)
  when 'spam_complaint'
    handle_spam_complaint_event(event)
  when 'unsubscribe'
    handle_unsubscribe_event(event)
  else
    puts "Unknown event type: #{event_type}"
  end
end

# Handle delivery events
def handle_delivery_event(event)
  # Update delivery status in your database
  # Example: mark_email_as_delivered(event['message_id'], event['timestamp'])

  puts "Email delivered successfully to #{event['email']}"
end

# Handle open events
def handle_open_event(event)
  # Track email opens
  client_info = {
    device: event['client_device'] || 'Unknown',
    os: event['client_os'] || 'Unknown',
    ip: event['client_ip'] || 'Unknown'
  }

  puts "Email opened by #{event['email']} on #{client_info[:device]} (#{client_info[:os]})"

  # Example: track_email_open(event['message_id'], client_info, event['timestamp'])
end

# Handle click events
def handle_click_event(event)
  url = event['url'] || 'Unknown URL'

  puts "Link clicked in email to #{event['email']}: #{url}"

  # Example: track_link_click(event['message_id'], url, event['timestamp'])
end

# Handle bounce events
def handle_bounce_event(event)
  bounce_type = event['is_hard'] ? 'hard' : 'soft'
  reason = event['text'] || 'Unknown reason'

  puts "Email bounced (#{bounce_type}) for #{event['email']}: #{reason}"

  # Handle hard bounces by suppressing the email
  nil unless event['is_hard']
  # Example: suppress_email(event['email'], 'hard_bounce')
end

# Handle drop events
def handle_drop_event(event)
  reason = event['reason'] || 'Unknown reason'

  puts "Email dropped for #{event['email']}: #{reason}"

  # Example: handle_email_drop(event['message_id'], reason)
end

# Handle spam complaint events
def handle_spam_complaint_event(event)
  puts "Spam complaint received for #{event['email']}"

  # Automatically unsubscribe users who mark emails as spam
  # Example: unsubscribe_email(event['email'], 'spam_complaint')
end

# Handle unsubscribe events
def handle_unsubscribe_event(event)
  group_id = event['unsubscribe_group_id']

  puts "Unsubscribe event for #{event['email']}" + (group_id ? " (Group: #{group_id})" : '')

  # Example: process_unsubscribe(event['email'], group_id)
end

# Webhook endpoint - only process POST requests
post '/webhook' do
  handle_webhook
end

# Show usage information for GET requests
get '/webhook' do
  content_type :html

  test_signature = Laneful::WebhookVerifier.generate_signature(
    'test-secret',
    "{\"event\":\"delivery\",\"email\":\"test@example.com\",\"lane_id\":\"5805dd85-ed8c-44db-91a7-1d53a41c86a5\",\"message_id\":\"test\",\"timestamp\":#{Time.now.to_i}}",
    include_prefix: true
  )

  <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
            <title>Laneful Webhook Endpoint</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; }
                .code { background: #f5f5f5; padding: 15px; border-radius: 5px; font-family: monospace; }
                .success { color: #28a745; }
                .info { background: #e7f3ff; padding: 15px; border-radius: 5px; border-left: 4px solid #0066cc; }
            </style>
        </head>
        <body>
            <h1>🚀 Laneful Webhook Endpoint</h1>
            <p>This endpoint is ready to receive Laneful webhook events.</p>
    #{'        '}
            <div class="info">
                <h3>Webhook Configuration</h3>
                <p><strong>Header:</strong> #{Laneful::WebhookVerifier.signature_header_name}</p>
                <p><strong>Supported Events:</strong> delivery, open, click, bounce, drop, spam_complaint, unsubscribe</p>
                <p><strong>Payload Formats:</strong> Single event (object) or Batch mode (array)</p>
            </div>

            <h3>Test Webhook Verification</h3>
            <div class="code">
    curl -X POST http://localhost:#{settings.port}/webhook \\
      -H "Content-Type: application/json" \\
      -H "#{Laneful::WebhookVerifier.signature_header_name}: sha256=#{test_signature}" \\
      -d '{"event":"delivery","email":"test@example.com","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"test","timestamp":#{Time.now.to_i}}'
            </div>

            <h3>Implementation Features</h3>
            <ul>
                <li class="success">✅ Signature verification with sha256= prefix support</li>
                <li class="success">✅ Batch and single event mode detection</li>
                <li class="success">✅ Payload structure validation</li>
                <li class="success">✅ All documented event types supported</li>
                <li class="success">✅ Header extraction with fallback formats</li>
                <li class="success">✅ Comprehensive error handling</li>
            </ul>
        </body>
        </html>
  HTML
end

# Start the server
puts "Starting Laneful webhook server on port #{settings.port}"
puts "Webhook endpoint: http://localhost:#{settings.port}/webhook"
puts "Configuration page: http://localhost:#{settings.port}/webhook"
