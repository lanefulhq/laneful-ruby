#!/usr/bin/env ruby
# frozen_string_literal: true

require '/app/lib/laneful'

# Batch Email Sending Example
# Based on RubySDK.tsx documentation Examples section

puts '📧 Laneful Ruby SDK - Batch Email Example'
puts '=========================================='

# Get configuration from environment variables
base_url = ENV['LANEFUL_BASE_URL']
auth_token = ENV['LANEFUL_AUTH_TOKEN']
from_email = ENV['LANEFUL_FROM_EMAIL']
to_emails = ENV['LANEFUL_TO_EMAILS']

if base_url.nil? || auth_token.nil? || from_email.nil? || to_emails.nil?
  puts '❌ Missing required environment variables:'
  puts '   LANEFUL_BASE_URL, LANEFUL_AUTH_TOKEN, LANEFUL_FROM_EMAIL, LANEFUL_TO_EMAILS'
  exit 1
end

# Parse recipient emails (comma-separated)
recipients = to_emails.split(',').map(&:strip)
if recipients.length < 2
  puts '❌ Need at least 2 recipient emails for batch sending'
  exit 1
end

begin
  # Create client
  client = Laneful::Client.new(base_url, auth_token)
  
  # Create multiple emails for batch sending
  emails = [
    Laneful::Email::Builder.new
      .from(Laneful::Address.new(from_email, 'Laneful SDK'))
      .to(Laneful::Address.new(recipients[0], 'User One'))
      .subject('Batch Email 1')
      .text_content('This is the first email in the batch.')
      .build,
    Laneful::Email::Builder.new
      .from(Laneful::Address.new(from_email, 'Laneful SDK'))
      .to(Laneful::Address.new(recipients[1], 'User Two'))
      .subject('Batch Email 2')
      .text_content('This is the second email in the batch.')
      .build
  ]
  
  # Send batch emails
  response = client.send_emails(emails)
  puts '✓ Batch emails sent successfully!'
  puts "Response: #{response}"
  
rescue Laneful::ValidationException => e
  puts "✗ Validation error: #{e.message}"
rescue Laneful::ApiException => e
  puts "✗ API error: #{e.message}"
  puts "Status code: #{e.status_code}"
rescue Laneful::HttpException => e
  puts "✗ HTTP error: #{e.message}"
rescue StandardError => e
  puts "✗ Unexpected error: #{e.message}"
end
