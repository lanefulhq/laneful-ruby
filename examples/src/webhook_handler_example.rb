#!/usr/bin/env ruby
# frozen_string_literal: true

require '/app/lib/laneful'

# Webhook Handler Example
# Based on RubySDK.tsx documentation Examples section

puts '📧 Laneful Ruby SDK - Webhook Handler Example'
puts '=============================================='

# Get configuration from environment variables
webhook_secret = ENV['LANEFUL_WEBHOOK_SECRET']
webhook_url = ENV['LANEFUL_WEBHOOK_URL']

if webhook_secret.nil? || webhook_url.nil?
  puts '❌ Missing required environment variables:'
  puts '   LANEFUL_WEBHOOK_SECRET, LANEFUL_WEBHOOK_URL'
  exit 1
end

# Sample webhook payload (in real usage, this would come from HTTP request)
# Using array format as expected by WebhookVerifier
sample_payload = <<~JSON
  [
    {
      "event": "delivery",
      "email": "user@example.com",
      "lane_id": "5805dd85-ed8c-44db-91a7-1d53a41c86a5",
      "message_id": "H-1-019844e340027d728a7cfda632e14d0a",
      "timestamp": 1640995200
    },
    {
      "event": "open",
      "email": "user@example.com",
      "lane_id": "5805dd85-ed8c-44db-91a7-1d53a41c86a5",
      "message_id": "H-1-019844e340027d728a7cfda632e14d0b",
      "timestamp": 1640995260
    }
  ]
JSON

# Generate a valid signature using the webhook secret (like in Python tests)
valid_signature = Laneful::WebhookVerifier.generate_signature(webhook_secret, sample_payload, include_prefix: true)

# Sample headers with valid signature (in real usage, these would come from HTTP request)
sample_headers = {
  'HTTP_X_WEBHOOK_SIGNATURE' => valid_signature,
  'CONTENT_TYPE' => 'application/json'
}

puts "Testing webhook verification with sample payload..."
puts "Webhook URL: #{webhook_url}"
puts "Sample payload: #{sample_payload.strip}"
puts "Generated signature: #{valid_signature}"

begin
  # Step 1: Extract signature from headers (as documented)
  signature = Laneful::WebhookVerifier.extract_signature_from_headers(sample_headers)
  if signature.nil?
    puts '❌ Missing webhook signature header'
    exit 1
  end
  
  puts "✓ Extracted signature: #{signature}"
  
  # Step 2: Verify signature (supports sha256= prefix as documented)
  unless Laneful::WebhookVerifier.verify_signature(webhook_secret, sample_payload, signature)
    puts '❌ Invalid webhook signature'
    exit 1
  end
  
  puts '✓ Signature verification successful'
  
  # Step 3: Parse and validate payload structure
  webhook_data = Laneful::WebhookVerifier.parse_webhook_payload(sample_payload)
  puts "✓ Payload parsed successfully"
  puts "  Batch mode: #{webhook_data[:is_batch]}"
  puts "  Events count: #{webhook_data[:events].length}"
  
  # Step 4: Process events (handles both batch and single event formats)
  webhook_data[:events].each do |event|
    event_type = event['event']
    email = event['email']
    
    case event_type
    when 'delivery'
      puts "📧 Email delivered to: #{email}"
    when 'open'
      puts "👁️  Email opened by: #{email}"
    when 'click'
      url = event['url'] || 'Unknown URL'
      puts "🔗 Link clicked by #{email}: #{url}"
    when 'bounce'
      is_hard = event['is_hard'] || false
      puts "📤 Email bounced (#{is_hard ? 'hard' : 'soft'}) for: #{email}"
    when 'drop'
      reason = event['reason'] || 'Unknown reason'
      puts "📥 Email dropped for #{email}: #{reason}"
    when 'spam_complaint'
      puts "🚫 Spam complaint for #{email}"
    when 'unsubscribe'
      puts "🚪 Unsubscribe event for #{email}"
    else
      puts "❓ Unknown event type: #{event_type}"
    end
  end
  
  puts '✓ Webhook processing completed successfully!'
  
rescue ArgumentError => e
  puts "✗ Payload validation error: #{e.message}"
rescue StandardError => e
  puts "✗ Webhook processing error: #{e.message}"
end
