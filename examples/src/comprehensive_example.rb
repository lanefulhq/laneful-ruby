#!/usr/bin/env ruby
# frozen_string_literal: true

require '/app/lib/laneful'

# Comprehensive Example - Demonstrates all features
# Based on RubySDK.tsx documentation with all examples combined

puts '📧 Laneful Ruby SDK - Comprehensive Example'
puts '============================================'

# Get configuration from environment variables
base_url = ENV['LANEFUL_BASE_URL']
auth_token = ENV['LANEFUL_AUTH_TOKEN']
from_email = ENV['LANEFUL_FROM_EMAIL']
to_emails = ENV['LANEFUL_TO_EMAILS']
template_id = ENV['LANEFUL_TEMPLATE_ID']

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
  puts '✓ Client created successfully'
  
  # Test 1: Basic Email
  puts "\n📝 Test 1: Basic Email"
  puts '----------------------'
  
  basic_email = Laneful::Email::Builder.new
    .from(Laneful::Address.new(from_email, 'Laneful SDK'))
    .to(Laneful::Address.new(recipients[0], 'Test Recipient'))
    .subject('Comprehensive Test - Basic Email')
    .text_content('This is a basic email test from the comprehensive example.')
    .build
  
  response1 = client.send_email(basic_email)
  puts '✓ Basic email sent successfully!'
  
  # Test 2: HTML Email with Tracking
  puts "\n🎨 Test 2: HTML Email with Tracking"
  puts '-----------------------------------'
  
  tracking = Laneful::TrackingSettings.new(opens: true, clicks: true, unsubscribes: false)
  
  html_email = Laneful::Email::Builder.new
    .from(Laneful::Address.new(from_email, 'Laneful SDK'))
    .to(Laneful::Address.new(recipients[0], 'Test Recipient'))
    .subject('Comprehensive Test - HTML with Tracking')
    .html_content('<h1>Comprehensive Test</h1><p>This is an <strong>HTML email</strong> with tracking enabled.</p><p><a href="https://example.com">Click here</a> to test click tracking.</p>')
    .text_content('Comprehensive Test - This is an HTML email with tracking enabled. Visit https://example.com to test click tracking.')
    .tracking(tracking)
    .tag('comprehensive-test')
    .build
  
  response2 = client.send_email(html_email)
  puts '✓ HTML email with tracking sent successfully!'
  
  # Test 3: Multiple Recipients (if we have enough recipients)
  if recipients.length >= 2
    puts "\n👥 Test 3: Multiple Recipients"
    puts '-------------------------------'
    
    multi_email = Laneful::Email::Builder.new
      .from(Laneful::Address.new(from_email, 'Laneful SDK'))
      .to(Laneful::Address.new(recipients[0], 'User One'))
      .to(Laneful::Address.new(recipients[1], 'User Two'))
      .subject('Comprehensive Test - Multiple Recipients')
      .text_content('This email is being sent to multiple recipients.')
      .reply_to(Laneful::Address.new(from_email, 'Reply To'))
      .build
    
    response3 = client.send_email(multi_email)
    puts '✓ Multiple recipients email sent successfully!'
  end
  
  # Test 4: Template Email (if template_id is provided)
  if template_id
    puts "\n📋 Test 4: Template Email"
    puts '-------------------------'
    
    template_email = Laneful::Email::Builder.new
      .from(Laneful::Address.new(from_email, 'Laneful SDK'))
      .to(Laneful::Address.new(recipients[0], 'Test Recipient'))
      .subject('Comprehensive Test - Template Email')
      .template_id(template_id)
      .template_data({
        'name' => 'John Doe',
        'company' => 'Acme Corporation',
        'activation_link' => 'https://example.com/activate'
      })
      .build
    
    response4 = client.send_email(template_email)
    puts '✓ Template email sent successfully!'
  end
  
  # Test 5: Batch Email (if we have enough recipients)
  if recipients.length >= 2
    puts "\n📦 Test 5: Batch Email"
    puts '----------------------'
    
    batch_emails = [
      Laneful::Email::Builder.new
        .from(Laneful::Address.new(from_email, 'Laneful SDK'))
        .to(Laneful::Address.new(recipients[0], 'User One'))
        .subject('Comprehensive Test - Batch Email 1')
        .text_content('This is the first email in the batch.')
        .build,
      Laneful::Email::Builder.new
        .from(Laneful::Address.new(from_email, 'Laneful SDK'))
        .to(Laneful::Address.new(recipients[1], 'User Two'))
        .subject('Comprehensive Test - Batch Email 2')
        .text_content('This is the second email in the batch.')
        .build
    ]
    
    response5 = client.send_emails(batch_emails)
    puts '✓ Batch emails sent successfully!'
  end
  
  puts "\n🎉 Comprehensive test completed successfully!"
  puts "\n📋 Summary:"
  puts '   • Basic email functionality ✓'
  puts '   • HTML email with tracking ✓'
  puts '   • Multiple recipients ✓' if recipients.length >= 2
  puts '   • Template email ✓' if template_id
  puts '   • Batch email sending ✓' if recipients.length >= 2
  puts '   • Error handling ✓'
  puts "\n💡 Check your email inboxes for the test emails!"
  
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
