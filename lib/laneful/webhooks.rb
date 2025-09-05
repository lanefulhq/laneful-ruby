# frozen_string_literal: true

module Laneful
  # Utility class for verifying webhook signatures
  class WebhookVerifier
    ALGORITHM = 'sha256'

    # Verifies a webhook signature
    def self.verify_signature(secret, payload, signature)
      return false if secret.nil? || secret.strip.empty?
      return false if payload.nil?
      return false if signature.nil? || signature.strip.empty?

      expected_signature = generate_signature(secret, payload)
      secure_compare?(expected_signature, signature)
    rescue StandardError
      false
    end

    # Generates a signature for the given payload
    def self.generate_signature(secret, payload)
      digest = OpenSSL::Digest.new(ALGORITHM)
      hmac = OpenSSL::HMAC.new(secret, digest)
      hmac.update(payload)
      hmac.hexdigest
    end

    # Compares two strings in constant time to prevent timing attacks
    def self.secure_compare?(str_a, str_b)
      return false unless str_a.bytesize == str_b.bytesize

      l = str_a.unpack("C#{str_a.bytesize}")
      res = 0
      str_b.each_byte { |byte| res |= byte ^ l.shift }
      res.zero?
    end
  end
end
