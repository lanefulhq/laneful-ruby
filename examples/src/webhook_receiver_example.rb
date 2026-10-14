#!/usr/bin/env ruby
# frozen_string_literal: true

# Receives Laneful webhooks over HTTP: verifies the signature, then processes single or batch events.
#
#   cd examples && bundle install
#   LANEFUL_WEBHOOK_SECRET=your-webhook-secret bundle exec ruby src/webhook_receiver_example.rb

require 'json'
require 'sinatra/base'
require_relative '../../lib/laneful'

$stdout.sync = true # Log each event immediately, also when output is piped

webhook_secret = ENV.fetch('LANEFUL_WEBHOOK_SECRET', '')
if webhook_secret.empty?
  # Without a secret every signature check fails, so refuse to start.
  puts '❌ Missing required environment variable: LANEFUL_WEBHOOK_SECRET'
  exit 1
end

# Sinatra app that verifies and logs Laneful webhook deliveries.
class WebhookReceiver < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, ENV.fetch('PORT', '8000').to_i
  set :server, 'webrick'
  set :host_authorization, { permitted_hosts: [] } # Accept any Host header (e.g. behind a tunnel)

  post '/' do
    # Verify the raw body: re-serializing parsed JSON can change the bytes.
    payload = request.body.read
    signature = request.env['HTTP_X_WEBHOOK_SIGNATURE']

    unless Laneful::WebhookVerifier.verify_signature(settings.webhook_secret, payload, signature)
      halt 401, 'Invalid signature'
    end

    begin
      webhook_data = Laneful::WebhookVerifier.parse_webhook_payload(payload)
    rescue ArgumentError => e
      puts "Invalid webhook payload: #{e.message}"
      halt 400, 'Invalid payload'
    end

    webhook_data[:events].each do |event|
      puts "[#{event['event']}] id=#{event['id']} message_id=#{event['message_id']} event=#{event.to_json}"
    end
    'OK'
  end
end

WebhookReceiver.set :webhook_secret, webhook_secret
puts "Webhook example listening on http://localhost:#{WebhookReceiver.port}/"
WebhookReceiver.run!
