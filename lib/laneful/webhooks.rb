# frozen_string_literal: true

require 'json'
require 'openssl'

module Laneful
  # Utility class for verifying webhook signatures and processing webhook payloads
  class WebhookVerifier
    ALGORITHM = 'sha256'
    SIGNATURE_PREFIX = 'sha256='
    SIGNATURE_HEADER_NAME = 'x-webhook-signature'

    # Valid event types as documented
    VALID_EVENT_TYPES = %w[
      delivery open click drop spam_complaint unsubscribe bounce
    ].freeze

    # UUID pattern for lane_id validation
    UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

    # Verifies a webhook signature with support for sha256= prefix
    # @param secret [String] The webhook secret
    # @param payload [String] The webhook payload
    # @param signature [String] The signature to verify (may include 'sha256=' prefix)
    # @return [Boolean] true if the signature is valid, false otherwise
    def self.verify_signature(secret, payload, signature)
      return false if secret.nil? || secret.strip.empty?
      return false if payload.nil?
      return false if signature.nil? || signature.strip.empty?

      # Handle sha256= prefix as documented
      clean_signature = if signature.start_with?(SIGNATURE_PREFIX)
                          signature[SIGNATURE_PREFIX.length..]
                        else
                          signature
                        end

      expected_signature = generate_signature(secret, payload)
      secure_compare?(expected_signature, clean_signature)
    rescue StandardError
      false
    end

    # Generates a signature for the given payload
    # @param secret [String] The webhook secret
    # @param payload [String] The payload to sign
    # @param include_prefix [Boolean] Whether to include the 'sha256=' prefix
    # @return [String] The generated signature
    def self.generate_signature(secret, payload, include_prefix: false)
      digest = OpenSSL::Digest.new(ALGORITHM)
      hmac = OpenSSL::HMAC.new(secret, digest)
      hmac.update(payload)
      signature = hmac.hexdigest
      include_prefix ? "#{SIGNATURE_PREFIX}#{signature}" : signature
    end

    # Parse and validate webhook payload structure
    # @param payload [String] The raw webhook payload JSON
    # @return [Hash] Hash containing :is_batch boolean and :events array
    # @raise [ArgumentError] If payload is invalid JSON or structure
    def self.parse_webhook_payload(payload)
      raise ArgumentError, 'Payload cannot be empty' if payload.nil? || payload.strip.empty?

      data = JSON.parse(payload)

      if data.is_a?(Array)
        # Batch mode: array of events
        events = data.map { |event| validate_and_parse_event(event) }
        { is_batch: true, events: events }
      elsif data.is_a?(Hash) && data.key?('event')
        # Single event mode
        event = validate_and_parse_event(data)
        { is_batch: false, events: [event] }
      else
        raise ArgumentError, 'Invalid webhook payload structure'
      end
    rescue JSON::ParserError => e
      raise ArgumentError, "Invalid JSON payload: #{e.message}"
    end

    # Get the webhook header name as documented
    # @return [String] The correct header name for webhook signatures
    def self.signature_header_name
      SIGNATURE_HEADER_NAME
    end

    # Extract webhook signature from HTTP headers (supports multiple formats)
    # @param headers [Hash] HTTP headers hash
    # @return [String, nil] The webhook signature or nil if not found
    def self.extract_signature_from_headers(headers)
      return nil if headers.nil?

      # Try documented header name first
      signature = headers[SIGNATURE_HEADER_NAME]
      return signature if signature

      # Try uppercase version
      upper_header = SIGNATURE_HEADER_NAME.upcase.tr('-', '_')
      signature = headers[upper_header]
      return signature if signature

      # Try with HTTP_ prefix (common in Rack environments)
      server_header = "HTTP_#{upper_header}"
      signature = headers[server_header]
      return signature if signature

      nil
    end

    # Compares two strings in constant time to prevent timing attacks
    # @param str_a [String] First string
    # @param str_b [String] Second string
    # @return [Boolean] true if strings are equal, false otherwise
    def self.secure_compare?(str_a, str_b)
      return false unless str_a.bytesize == str_b.bytesize

      l = str_a.unpack("C#{str_a.bytesize}")
      res = 0
      str_b.each_byte { |byte| res |= byte ^ l.shift }
      res.zero?
    end

    # Validate individual event structure according to documentation
    # @param event [Hash] The event data
    # @return [Hash] Parsed event hash
    # @raise [ArgumentError] If event structure is invalid
    def self.validate_and_parse_event(event)
      raise ArgumentError, 'Event must be a hash' unless event.is_a?(Hash)

      # Required fields
      required_fields = %w[event email lane_id message_id timestamp]
      required_fields.each do |field|
        raise ArgumentError, "Missing required field: #{field}" unless event.key?(field)
      end

      # Validate event type
      event_type = event['event']
      raise ArgumentError, "Invalid event type: #{event_type}" unless VALID_EVENT_TYPES.include?(event_type)

      # Validate email format
      email = event['email']
      raise ArgumentError, "Invalid email format: #{email}" unless valid_email?(email)

      # Validate timestamp is numeric
      timestamp = event['timestamp']
      begin
        Integer(timestamp)
      rescue ArgumentError, TypeError
        raise ArgumentError, 'Invalid timestamp format'
      end

      # Validate lane_id is a valid UUID format
      lane_id = event['lane_id']
      raise ArgumentError, "Invalid lane_id format: #{lane_id}" unless UUID_PATTERN.match?(lane_id)

      # Return event with all fields (required + optional)
      event
    end

    # Simple email validation
    # @param email [String] The email to validate
    # @return [Boolean] true if email format is valid
    def self.valid_email?(email)
      email.is_a?(String) && email.include?('@') && email.include?('.')
    end
  end
end
