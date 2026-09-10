#!/usr/bin/env ruby
# frozen_string_literal: true

require '/app/lib/laneful'

puts '📧 Laneful Ruby SDK - Mail Settings Example'
puts '==========================================='

base_url = ENV['LANEFUL_BASE_URL']
auth_token = ENV['LANEFUL_AUTH_TOKEN']
from_email = ENV['LANEFUL_FROM_EMAIL']
to_emails = ENV['LANEFUL_TO_EMAILS']

if base_url.nil? || auth_token.nil? || from_email.nil? || to_emails.nil?
  puts '❌ Missing LANEFUL_BASE_URL, LANEFUL_AUTH_TOKEN, LANEFUL_FROM_EMAIL, LANEFUL_TO_EMAILS'
  exit 1
end

to_email = to_emails.split(',').map(&:strip).first

begin
  client = Laneful::Client.new(base_url, auth_token)

  email = Laneful::Email::Builder.new
                                 .from(Laneful::Address.new(from_email, 'Your Name'))
                                 .from_header(Laneful::Address.new(from_email, 'Newsletter'))
                                 .to(Laneful::Address.new(to_email, 'Recipient Name'))
                                 .subject('Sandbox email')
                                 .text_content('This email is sent with sandbox mode and returns message IDs.')
                                 .tracking(Laneful::TrackingSettings.new(
                                             opens: true,
                                             clicks: true,
                                             unsubscribes: false,
                                             unsubscribe_group_name: 'Newsletters'
                                           ))
                                 .build

  response = client.send_email(
    email,
    Laneful::MailSettings.new(sandbox_mode: true, return_message_ids: true)
  )
  puts '✓ Email sent successfully'
  puts "Response: #{response}"
rescue Laneful::ValidationException => e
  puts "✗ Validation error: #{e.message}"
rescue Laneful::ApiException => e
  puts "✗ API error: #{e.message}"
rescue Laneful::HttpException => e
  puts "✗ HTTP error: #{e.message}"
end
