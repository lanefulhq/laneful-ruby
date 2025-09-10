#!/usr/bin/env ruby
# frozen_string_literal: true

require '/app/lib/laneful'

# Scheduled Email Example
# Based on RubySDK.tsx documentation Examples section

puts '📧 Laneful Ruby SDK - Scheduled Email Example'
puts '=============================================='

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
  
  # Schedule for 1 minute from now (for testing purposes)
  send_time = Time.now.to_i + 60
  
  # Create scheduled email
  email = Laneful::Email::Builder.new
    .from(Laneful::Address.new(from_email, 'Laneful SDK'))
    .to(Laneful::Address.new(recipients[0], 'Test Recipient'))
    .subject('Scheduled Email')
    .text_content('This email was scheduled to be sent 1 minute after the request was made.')
    .send_time(send_time)
    .build
  
  # Send email
  response = client.send_email(email)
  puts '✓ Scheduled email sent successfully!'
  puts "Scheduled for: #{Time.at(send_time)}"
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
