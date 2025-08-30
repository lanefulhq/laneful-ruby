require "spec_helper"

RSpec.describe Laneful::Address do
  describe "#initialize" do
    it "creates an address with email and name" do
      address = described_class.new("test@example.com", "Test User")
      expect(address.email).to eq("test@example.com")
      expect(address.name).to eq("Test User")
    end

    it "creates an address with email only" do
      address = described_class.new("test@example.com")
      expect(address.email).to eq("test@example.com")
      expect(address.name).to be_nil
    end

    it "raises ValidationException with empty email" do
      expect { described_class.new("") }.to raise_error(Laneful::ValidationException)
    end

    it "raises ValidationException with nil email" do
      expect { described_class.new(nil) }.to raise_error(Laneful::ValidationException)
    end

    it "raises ValidationException with invalid email format" do
      expect { described_class.new("invalid-email") }.to raise_error(Laneful::ValidationException)
    end
  end

  describe "#to_hash" do
    it "returns hash with email and name" do
      address = described_class.new("test@example.com", "Test User")
      expect(address.to_hash).to eq({
        "email" => "test@example.com",
        "name" => "Test User"
      })
    end

    it "returns hash with email only when name is nil" do
      address = described_class.new("test@example.com")
      expect(address.to_hash).to eq({
        "email" => "test@example.com"
      })
    end
  end

  describe "#to_s" do
    it "returns formatted string with name and email" do
      address = described_class.new("test@example.com", "Test User")
      expect(address.to_s).to eq("Test User <test@example.com>")
    end

    it "returns email only when name is nil" do
      address = described_class.new("test@example.com")
      expect(address.to_s).to eq("test@example.com")
    end
  end

  describe "#==" do
    it "returns true for equal addresses" do
      address1 = described_class.new("test@example.com", "Test User")
      address2 = described_class.new("test@example.com", "Test User")
      expect(address1).to eq(address2)
    end

    it "returns false for different addresses" do
      address1 = described_class.new("test1@example.com", "Test User")
      address2 = described_class.new("test2@example.com", "Test User")
      expect(address1).not_to eq(address2)
    end
  end
end

RSpec.describe Laneful::TrackingSettings do
  describe "#initialize" do
    it "creates tracking settings with default values" do
      tracking = described_class.new
      expect(tracking.opens).to be false
      expect(tracking.clicks).to be false
      expect(tracking.unsubscribes).to be false
    end

    it "creates tracking settings with custom values" do
      tracking = described_class.new(opens: true, clicks: true, unsubscribes: false)
      expect(tracking.opens).to be true
      expect(tracking.clicks).to be true
      expect(tracking.unsubscribes).to be false
    end
  end

  describe "#to_hash" do
    it "returns hash with tracking settings" do
      tracking = described_class.new(opens: true, clicks: false, unsubscribes: true)
      expect(tracking.to_hash).to eq({
        "opens" => true,
        "clicks" => false,
        "unsubscribes" => true
      })
    end
  end

  describe "#==" do
    it "returns true for equal tracking settings" do
      tracking1 = described_class.new(opens: true, clicks: false, unsubscribes: true)
      tracking2 = described_class.new(opens: true, clicks: false, unsubscribes: true)
      expect(tracking1).to eq(tracking2)
    end
  end
end

RSpec.describe Laneful::Attachment do
  let(:temp_file) { Tempfile.new(["test", ".txt"]) }

  before do
    temp_file.write("test content")
    temp_file.close
  end

  after do
    temp_file.unlink
  end

  describe "#initialize" do
    it "creates attachment with valid parameters" do
      attachment = described_class.new("test.txt", "text/plain", "dGVzdCBjb250ZW50")
      expect(attachment.filename).to eq("test.txt")
      expect(attachment.content_type).to eq("text/plain")
      expect(attachment.content).to eq("dGVzdCBjb250ZW50")
    end

    it "raises ValidationException with empty filename" do
      expect { described_class.new("", "text/plain", "content") }.to raise_error(Laneful::ValidationException)
    end

    it "raises ValidationException with empty content_type" do
      expect { described_class.new("test.txt", "", "content") }.to raise_error(Laneful::ValidationException)
    end

    it "raises ValidationException with empty content" do
      expect { described_class.new("test.txt", "text/plain", "") }.to raise_error(Laneful::ValidationException)
    end
  end

  describe ".from_file" do
    it "creates attachment from file" do
      attachment = described_class.from_file(temp_file.path)
      expect(attachment.filename).to eq(File.basename(temp_file.path))
      expect(attachment.content_type).to eq("text/plain")
      expect(attachment.content).to eq(Base64.strict_encode64("test content"))
    end
  end

  describe "#to_hash" do
    it "returns hash with attachment data" do
      attachment = described_class.new("test.txt", "text/plain", "dGVzdCBjb250ZW50")
      expect(attachment.to_hash).to eq({
        "filename" => "test.txt",
        "content_type" => "text/plain",
        "content" => "dGVzdCBjb250ZW50"
      })
    end
  end
end

RSpec.describe Laneful::Email do
  describe "#initialize" do
    let(:builder) do
      Laneful::Email::Builder.new
        .from(Laneful::Address.new("sender@example.com"))
        .to(Laneful::Address.new("recipient@example.com"))
        .subject("Test Subject")
        .text_content("Test content")
    end

    it "creates email with required fields" do
      email = builder.build
      expect(email.from.email).to eq("sender@example.com")
      expect(email.to.size).to eq(1)
      expect(email.to.first.email).to eq("recipient@example.com")
      expect(email.subject).to eq("Test Subject")
      expect(email.text_content).to eq("Test content")
    end

    it "raises ValidationException without from address" do
      builder.instance_variable_set(:@from, nil)
      expect { builder.build }.to raise_error(Laneful::ValidationException)
    end

    it "raises ValidationException without recipients" do
      builder.instance_variable_set(:@to, [])
      builder.instance_variable_set(:@cc, [])
      builder.instance_variable_set(:@bcc, [])
      expect { builder.build }.to raise_error(Laneful::ValidationException)
    end

    it "raises ValidationException without content or template" do
      builder.instance_variable_set(:@text_content, nil)
      builder.instance_variable_set(:@html_content, nil)
      builder.instance_variable_set(:@template_id, nil)
      expect { builder.build }.to raise_error(Laneful::ValidationException)
    end

    it "accepts HTML content instead of text content" do
      builder.instance_variable_set(:@text_content, nil)
      builder.html_content("<h1>Test</h1>")
      email = builder.build
      expect(email.html_content).to eq("<h1>Test</h1>")
    end

    it "accepts template_id instead of content" do
      builder.instance_variable_set(:@text_content, nil)
      builder.instance_variable_set(:@html_content, nil)
      builder.template_id("test-template")
      email = builder.build
      expect(email.template_id).to eq("test-template")
    end
  end

  describe "#to_hash" do
    let(:email) do
      Laneful::Email::Builder.new
        .from(Laneful::Address.new("sender@example.com"))
        .to(Laneful::Address.new("recipient@example.com"))
        .subject("Test Subject")
        .text_content("Test content")
        .build
    end

    it "returns hash with required fields" do
      hash = email.to_hash
      expect(hash["from"]).to eq({ "email" => "sender@example.com" })
      expect(hash["to"]).to eq([{ "email" => "recipient@example.com" }])
      expect(hash["subject"]).to eq("Test Subject")
      expect(hash["text_content"]).to eq("Test content")
    end

    it "excludes nil fields" do
      hash = email.to_hash
      expect(hash).not_to have_key("html_content")
      expect(hash).not_to have_key("template_id")
      expect(hash).not_to have_key("attachments")
    end
  end

  describe "#==" do
    it "returns true for equal emails" do
      email1 = Laneful::Email::Builder.new
        .from(Laneful::Address.new("sender@example.com"))
        .to(Laneful::Address.new("recipient@example.com"))
        .subject("Test Subject")
        .text_content("Test content")
        .build

      email2 = Laneful::Email::Builder.new
        .from(Laneful::Address.new("sender@example.com"))
        .to(Laneful::Address.new("recipient@example.com"))
        .subject("Test Subject")
        .text_content("Test content")
        .build

      expect(email1).to eq(email2)
    end
  end
end

