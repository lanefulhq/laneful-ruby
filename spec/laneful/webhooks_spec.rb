# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Laneful::WebhookVerifier do
  let(:secret) { 'test-secret-key' }
  let(:valid_payload) do
    '{"event":"delivery","email":"user@example.com","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"H-1-019844e340027d728a7cfda632e14d0a","timestamp":1753502407}'
  end
  let(:signature) { described_class.generate_signature(secret, valid_payload) }

  describe '.verify_signature' do
    it 'returns true for valid signature without prefix' do
      expect(described_class.verify_signature(secret, valid_payload, signature)).to be true
    end

    it 'returns true for valid signature with sha256= prefix' do
      signature_with_prefix = "sha256=#{signature}"
      expect(described_class.verify_signature(secret, valid_payload, signature_with_prefix)).to be true
    end

    it 'returns false for invalid signature' do
      expect(described_class.verify_signature(secret, valid_payload, 'invalid-signature')).to be false
    end

    it 'returns false for empty secret' do
      expect(described_class.verify_signature('', valid_payload, signature)).to be false
    end

    it 'returns false for nil secret' do
      expect(described_class.verify_signature(nil, valid_payload, signature)).to be false
    end

    it 'returns false for nil payload' do
      expect(described_class.verify_signature(secret, nil, signature)).to be false
    end

    it 'returns false for empty signature' do
      expect(described_class.verify_signature(secret, valid_payload, '')).to be false
    end

    it 'returns false for nil signature' do
      expect(described_class.verify_signature(secret, valid_payload, nil)).to be false
    end

    it 'handles different payloads correctly' do
      payload2 = '{"event":"open","email":"user2@example.com","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"H-1-019844e340027d728a7cfda632e14d0b","timestamp":1753502500}'
      signature2 = described_class.generate_signature(secret, payload2)

      expect(described_class.verify_signature(secret, payload2, signature2)).to be true
      expect(described_class.verify_signature(secret, payload2, signature)).to be false
    end
  end

  describe '.generate_signature' do
    it 'generates consistent signatures for same input' do
      signature1 = described_class.generate_signature(secret, valid_payload)
      signature2 = described_class.generate_signature(secret, valid_payload)
      expect(signature1).to eq(signature2)
    end

    it 'generates different signatures for different secrets' do
      signature1 = described_class.generate_signature('secret1', valid_payload)
      signature2 = described_class.generate_signature('secret2', valid_payload)
      expect(signature1).not_to eq(signature2)
    end

    it 'generates different signatures for different payloads' do
      payload2 = '{"event":"open","email":"user@example.com","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"H-1-019844e340027d728a7cfda632e14d0a","timestamp":1753502407}'
      signature1 = described_class.generate_signature(secret, valid_payload)
      signature2 = described_class.generate_signature(secret, payload2)
      expect(signature1).not_to eq(signature2)
    end

    it 'generates hex-encoded signatures' do
      signature = described_class.generate_signature(secret, valid_payload)
      expect(signature).to match(/^[0-9a-f]+$/)
    end

    it 'generates signature without prefix by default' do
      signature = described_class.generate_signature(secret, valid_payload)
      expect(signature).not_to start_with('sha256=')
    end

    it 'generates signature with prefix when requested' do
      signature = described_class.generate_signature(secret, valid_payload, include_prefix: true)
      expect(signature).to start_with('sha256=')
    end
  end

  describe '.parse_webhook_payload' do
    it 'parses single event payload correctly' do
      payload = '{"event":"delivery","email":"user@example.com","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"H-1-019844e340027d728a7cfda632e14d0a","timestamp":1753502407,"metadata":{"campaign_id":"test"},"tag":"newsletter"}'

      result = described_class.parse_webhook_payload(payload)

      expect(result[:is_batch]).to be false
      expect(result[:events].length).to eq(1)
      expect(result[:events].first['event']).to eq('delivery')
      expect(result[:events].first['email']).to eq('user@example.com')
    end

    it 'parses batch event payload correctly' do
      payload = '[{"event":"delivery","email":"user1@example.com","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"H-1-019844e340027d728a7cfda632e14d0a","timestamp":1753502407},{"event":"open","email":"user2@example.com","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"H-1-019844e340027d728a7cfda632e14d0b","timestamp":1753502500}]'

      result = described_class.parse_webhook_payload(payload)

      expect(result[:is_batch]).to be true
      expect(result[:events].length).to eq(2)
      expect(result[:events].first['event']).to eq('delivery')
      expect(result[:events].last['event']).to eq('open')
    end

    it 'validates all documented event types' do
      %w[delivery open click drop spam_complaint unsubscribe bounce].each do |event_type|
        payload = "{\"event\":\"#{event_type}\",\"email\":\"user@example.com\",\"lane_id\":\"5805dd85-ed8c-44db-91a7-1d53a41c86a5\",\"message_id\":\"H-1-019844e340027d728a7cfda632e14d0a\",\"timestamp\":1753502407}"

        result = described_class.parse_webhook_payload(payload)
        expect(result[:events].first['event']).to eq(event_type)
      end
    end

    it 'raises error for invalid JSON payload' do
      invalid_json = '{"event":"delivery","email"'

      expect do
        described_class.parse_webhook_payload(invalid_json)
      end.to raise_error(ArgumentError, /Invalid JSON payload/)
    end

    it 'raises error for missing required fields' do
      payload = '{"event":"delivery"}' # Missing required fields

      expect do
        described_class.parse_webhook_payload(payload)
      end.to raise_error(ArgumentError, /Missing required field: email/)
    end

    it 'raises error for invalid event type' do
      payload = '{"event":"invalid_event_type","email":"user@example.com","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"H-1-019844e340027d728a7cfda632e14d0a","timestamp":1753502407}'

      expect do
        described_class.parse_webhook_payload(payload)
      end.to raise_error(ArgumentError, /Invalid event type: invalid_event_type/)
    end

    it 'raises error for invalid email format' do
      payload = '{"event":"delivery","email":"not-an-email","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"H-1-019844e340027d728a7cfda632e14d0a","timestamp":1753502407}'

      expect do
        described_class.parse_webhook_payload(payload)
      end.to raise_error(ArgumentError, /Invalid email format/)
    end

    it 'raises error for invalid lane_id format' do
      payload = '{"event":"delivery","email":"user@example.com","lane_id":"not-a-uuid","message_id":"H-1-019844e340027d728a7cfda632e14d0a","timestamp":1753502407}'

      expect do
        described_class.parse_webhook_payload(payload)
      end.to raise_error(ArgumentError, /Invalid lane_id format/)
    end

    it 'raises error for invalid timestamp format' do
      payload = '{"event":"delivery","email":"user@example.com","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"H-1-019844e340027d728a7cfda632e14d0a","timestamp":"not-a-timestamp"}'

      expect do
        described_class.parse_webhook_payload(payload)
      end.to raise_error(ArgumentError, /Invalid timestamp format/)
    end

    it 'raises error for empty payload' do
      expect do
        described_class.parse_webhook_payload('')
      end.to raise_error(ArgumentError, /Payload cannot be empty/)
    end

    it 'raises error for nil payload' do
      expect do
        described_class.parse_webhook_payload(nil)
      end.to raise_error(ArgumentError, /Payload cannot be empty/)
    end
  end

  describe '.signature_header_name' do
    it 'returns the correct header name' do
      expect(described_class.signature_header_name).to eq('x-webhook-signature')
    end
  end

  describe '.extract_signature_from_headers' do
    it 'extracts signature from standard header' do
      headers = { 'x-webhook-signature' => 'sha256=abc123' }
      expect(described_class.extract_signature_from_headers(headers)).to eq('sha256=abc123')
    end

    it 'extracts signature from uppercase header' do
      headers = { 'X_WEBHOOK_SIGNATURE' => 'sha256=def456' }
      expect(described_class.extract_signature_from_headers(headers)).to eq('sha256=def456')
    end

    it 'extracts signature from HTTP_ prefixed header' do
      headers = { 'HTTP_X_WEBHOOK_SIGNATURE' => 'sha256=ghi789' }
      expect(described_class.extract_signature_from_headers(headers)).to eq('sha256=ghi789')
    end

    it 'returns nil for missing header' do
      headers = { 'other-header' => 'value' }
      expect(described_class.extract_signature_from_headers(headers)).to be_nil
    end

    it 'returns nil for nil headers' do
      expect(described_class.extract_signature_from_headers(nil)).to be_nil
    end
  end

  describe 'complete webhook verification workflow' do
    it 'handles the full webhook verification process' do
      # Test data from documentation examples
      event_data = '{"event":"delivery","email":"user@example.com","lane_id":"5805dd85-ed8c-44db-91a7-1d53a41c86a5","message_id":"H-1-019844e340027d728a7cfda632e14d0a","metadata":{"campaign_id":"camp_456","user_id":"user_123"},"tag":"newsletter-campaign","timestamp":1753502407}'

      signature = described_class.generate_signature(secret, event_data, include_prefix: true)

      # Simulate HTTP headers
      headers = { 'x-webhook-signature' => signature }

      # Step 1: Extract signature from headers
      extracted_signature = described_class.extract_signature_from_headers(headers)
      expect(extracted_signature).not_to be_nil

      # Step 2: Verify signature
      expect(described_class.verify_signature(secret, event_data, extracted_signature)).to be true

      # Step 3: Parse payload
      parsed = described_class.parse_webhook_payload(event_data)
      expect(parsed[:is_batch]).to be false
      expect(parsed[:events].length).to eq(1)
      expect(parsed[:events].first['event']).to eq('delivery')
      expect(parsed[:events].first['email']).to eq('user@example.com')
    end
  end
end
