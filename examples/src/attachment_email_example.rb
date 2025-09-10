#!/usr/bin/env ruby
# frozen_string_literal: true

require '/app/lib/laneful'

# Email with Attachments Example
# Based on RubySDK.tsx documentation Examples section

puts '📧 Laneful Ruby SDK - Email with Attachments Example'
puts '===================================================='

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
  
  # Create a simple text attachment (since we don't have a real file)
  attachment = Laneful::Attachment.new(
    'test-document.txt',
    'text/plain',
    'VGhpcyBpcyBhIHRlc3QgZG9jdW1lbnQgYXR0YWNobWVudC4=' # Base64 encoded "This is a test document attachment."
  )
  
  # Create email with attachment
  email = Laneful::Email::Builder.new
    .from(Laneful::Address.new(from_email, 'Laneful SDK'))
    .to(Laneful::Address.new(recipients[0], 'Test Recipient'))
    .subject('Document Attached')
    .text_content('Please find the document attached.')
    .attachment(attachment)
    .build
  
  # Send email
  response = client.send_email(email)
  puts '✓ Email with attachment sent successfully!'
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
