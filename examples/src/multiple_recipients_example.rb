#!/usr/bin/env ruby
# frozen_string_literal: true

require '/app/lib/laneful'

# Multiple Recipients with Reply-To Example
# Based on RubySDK.tsx documentation Examples section

puts '📧 Laneful Ruby SDK - Multiple Recipients Example'
puts '================================================='

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
  puts '❌ Need at least 2 recipient emails for this example'
  exit 1
end

begin
  # Create client
  client = Laneful::Client.new(base_url, auth_token)
  
  # Create email with multiple recipients
  email_builder = Laneful::Email::Builder.new
    .from(Laneful::Address.new(from_email, 'Laneful SDK'))
    .subject('Email to Multiple Recipients')
    .text_content('This email is being sent to multiple recipients.')
  
  # Add TO recipients
  recipients[0..1].each_with_index do |email, index|
    email_builder.to(Laneful::Address.new(email, "User #{index + 1}"))
  end
  
  # Add CC if we have more recipients
  if recipients.length > 2
    email_builder.cc(Laneful::Address.new(recipients[2], 'CC Recipient'))
  end
  
  # Add BCC if we have even more recipients
  if recipients.length > 3
    email_builder.bcc(Laneful::Address.new(recipients[3], 'BCC Recipient'))
  end
  
  # Add reply-to
  email_builder.reply_to(Laneful::Address.new(from_email, 'Reply To'))
  
  email = email_builder.build
  
  # Send email
  response = client.send_email(email)
  puts '✓ Email to multiple recipients sent successfully!'
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
