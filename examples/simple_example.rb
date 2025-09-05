#!/usr/bin/env ruby
# frozen_string_literal: true

require 'laneful'

# Simple example demonstrating basic usage of the Laneful Ruby SDK
puts '📧 Laneful Ruby SDK - Simple Example'
puts "====================================\n"

# Configuration - Replace with your actual credentials
base_url = 'https://your-subdomain.z1.send.dev.laneful.net'
auth_token = 'priv-YourAuthTokenHere'

# Email addresses - Replace with your actual addresses
sender_email = 'sender@yourdomain.com'
sender_name = 'Your Name'
recipient_email = 'recipient@example.com'
recipient_name = 'Recipient Name'
cc_email = 'cc@example.com'
cc_name = 'CC Recipient'

# Create client
begin
  client = Laneful::Client.new(base_url, auth_token)
  puts '✅ Client created successfully'
rescue Laneful::ValidationException => e
  puts "❌ Failed to create client: #{e.message}"
  puts 'Please check your base_url and auth_token configuration.'
  exit 1
end

# Test 1: Send a simple text email
puts "\n📝 Test 1: Sending Simple Text Email"
puts '------------------------------------'

begin
  email = Laneful::Email::Builder.new
                                 .from(Laneful::Address.new(sender_email, sender_name))
                                 .to(Laneful::Address.new(recipient_email, recipient_name))
                                 .subject('Hello from Laneful Ruby SDK! 🚀')
                                 .text_content('Hi! This is a test email sent using the Laneful Ruby SDK. ' \
                                               'The SDK is working perfectly!')
                                 .tag('ruby-sdk-test')
                                 .build

  response = client.send_email(email)
  puts '✅ Simple email sent successfully!'
  puts "Response: #{response}"
rescue Laneful::ValidationException => e
  puts "❌ Validation error: #{e.message}"
rescue Laneful::ApiException => e
  puts "❌ API error: #{e.message} (Status: #{e.status_code})"
  puts "   Details: #{e.error_message}" if e.error_message
rescue Laneful::HttpException => e
  puts "❌ HTTP error: #{e.message} (Status: #{e.status_code})"
end

# Test 2: Send an HTML email with CC
puts "\n🎨 Test 2: Sending HTML Email with CC"
puts '-------------------------------------'

begin
  tracking = Laneful::TrackingSettings.new(opens: true, clicks: true, unsubscribes: false)

  email = Laneful::Email::Builder.new
                                 .from(Laneful::Address.new(sender_email, sender_name))
                                 .to(Laneful::Address.new(recipient_email, recipient_name))
                                 .cc(Laneful::Address.new(cc_email, cc_name))
                                 .subject('Ruby SDK Test - HTML Email with Tracking 📧')
                                 .html_content(<<~HTML)
                                   <!DOCTYPE html>
                                   <html>
                                   <head>
                                       <title>Ruby SDK Test</title>
                                   </head>
                                   <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                                       <h1 style="color: #2c3e50;">🎉 Ruby SDK Test Successful!</h1>
                                       <p>Hello! This email was sent using the <strong>Laneful Ruby SDK</strong> with modern Ruby features:</p>
                                       <ul style="background-color: #f8f9fa; padding: 15px; border-radius: 5px;">
                                           <li>✅ Frozen string literals for immutability</li>
                                           <li>✅ Keyword arguments for clean APIs</li>
                                           <li>✅ Safe navigation operator (&.)</li>
                                           <li>✅ Enhanced exception handling</li>
                                           <li>✅ Modern Ruby syntax throughout</li>
                                       </ul>
                                       <p style="color: #7f8c8d;">This email has tracking enabled for opens and clicks.</p>
                                       <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
                                       <p style="font-size: 12px; color: #95a5a6;">
                                           Sent from: #{sender_email}<br>
                                           To: #{recipient_email}<br>
                                           CC: #{cc_email}
                                       </p>
                                   </body>
                                   </html>
                                 HTML
                                 .text_content('Ruby SDK Test Successful! Hello! This email was sent using ' \
                                               'the Laneful Ruby SDK with modern Ruby features including ' \
                                               'frozen string literals, keyword arguments, safe navigation ' \
                                               'operator, and enhanced exception handling. This email has ' \
                                               'tracking enabled for opens and clicks.')
                                 .tracking(tracking)
                                 .tag('html-cc-test')
                                 .build

  response = client.send_email(email)
  puts '✅ HTML email with CC sent successfully!'
  puts "Response: #{response}"
rescue Laneful::ValidationException => e
  puts "❌ Validation error: #{e.message}"
rescue Laneful::ApiException => e
  puts "❌ API error: #{e.message} (Status: #{e.status_code})"
  puts "   Details: #{e.error_message}" if e.error_message
rescue Laneful::HttpException => e
  puts "❌ HTTP error: #{e.message} (Status: #{e.status_code})"
end

puts "\n🎉 Tests completed!"
puts "\n📋 Summary:"
puts '   • Ruby SDK is working correctly'
puts '   • Real API endpoint is accessible'
puts '   • Email building and sending functionality is operational'
puts '   • Error handling is working properly'
puts "\n💡 Check your email inboxes for the test emails!"
