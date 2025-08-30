require "spec_helper"

RSpec.describe Laneful::WebhookVerifier do
  let(:secret) { "test-secret" }
  let(:payload) { '{"event": "email.sent", "data": {"id": "123"}}' }
  let(:signature) { described_class.generate_signature(secret, payload) }

  describe ".verify_signature" do
    it "returns true for valid signature" do
      expect(described_class.verify_signature(secret, payload, signature)).to be true
    end

    it "returns false for invalid signature" do
      expect(described_class.verify_signature(secret, payload, "invalid-signature")).to be false
    end

    it "returns false for empty secret" do
      expect(described_class.verify_signature("", payload, signature)).to be false
    end

    it "returns false for nil secret" do
      expect(described_class.verify_signature(nil, payload, signature)).to be false
    end

    it "returns false for nil payload" do
      expect(described_class.verify_signature(secret, nil, signature)).to be false
    end

    it "returns false for empty signature" do
      expect(described_class.verify_signature(secret, payload, "")).to be false
    end

    it "returns false for nil signature" do
      expect(described_class.verify_signature(secret, payload, nil)).to be false
    end

    it "handles different payloads correctly" do
      payload2 = '{"event": "email.opened", "data": {"id": "456"}}'
      signature2 = described_class.generate_signature(secret, payload2)
      
      expect(described_class.verify_signature(secret, payload2, signature2)).to be true
      expect(described_class.verify_signature(secret, payload2, signature)).to be false
    end
  end

  describe ".generate_signature" do
    it "generates consistent signatures for same input" do
      signature1 = described_class.generate_signature(secret, payload)
      signature2 = described_class.generate_signature(secret, payload)
      expect(signature1).to eq(signature2)
    end

    it "generates different signatures for different secrets" do
      signature1 = described_class.generate_signature("secret1", payload)
      signature2 = described_class.generate_signature("secret2", payload)
      expect(signature1).not_to eq(signature2)
    end

    it "generates different signatures for different payloads" do
      payload2 = '{"event": "email.opened"}'
      signature1 = described_class.generate_signature(secret, payload)
      signature2 = described_class.generate_signature(secret, payload2)
      expect(signature1).not_to eq(signature2)
    end

    it "generates hex-encoded signatures" do
      signature = described_class.generate_signature(secret, payload)
      expect(signature).to match(/^[0-9a-f]+$/)
    end
  end
end

