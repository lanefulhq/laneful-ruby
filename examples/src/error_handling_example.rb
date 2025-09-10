#!/usr/bin/env ruby
# frozen_string_literal: true

require '/app/lib/laneful'

# Error Handling Example
# Based on RubySDK.tsx documentation Error Handling section

puts '📧 Laneful Ruby SDK - Error Handling Example'
puts '============================================='

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
if recipients.empty?
  puts '❌ No recipient emails provided'
  exit 1
end

begin
  # Create client
  client = Laneful::Client.new(base_url, auth_token)
  
  # Create email
  email = Laneful::Email::Builder.new
    .from(Laneful::Address.new(from_email, 'Laneful SDK'))
    .to(Laneful::Address.new(recipients[0], 'Test Recipient'))
    .subject('Error Handling Test')
    .text_content('This email demonstrates comprehensive error handling.')
    .build
  
  # Send email with comprehensive error handling
  response = client.send_email(email)
  puts '✓ Email sent successfully!'
  puts "Response: #{response}"
  
rescue Laneful::ValidationException => e
  # Invalid input data
  puts "✗ Validation error: #{e.message}"
  puts 'Please check your email configuration'
rescue Laneful::ApiException => e
  # API returned an error
  puts "✗ API error: #{e.message}"
  puts "  Status code: #{e.status_code}"
  puts "  Error message: #{e.error_message}" if e.respond_to?(:error_message)
  puts 'Please check your API credentials and endpoint'
rescue Laneful::HttpException => e
  # Network or HTTP-level error
  puts "✗ HTTP error: #{e.message}"
  puts "  Status code: #{e.status_code}"
  puts 'Please check your network connection and endpoint URL'
rescue StandardError => e
  # Other unexpected errors
  puts "✗ Unexpected error: #{e.message}"
  puts e.backtrace
end
