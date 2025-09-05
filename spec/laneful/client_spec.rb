# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Laneful::Client do
  let(:base_url) { 'https://test.send.laneful.net' }
  let(:auth_token) { 'test-auth-token' }
  let(:client) { described_class.new(base_url, auth_token) }

  describe '#initialize' do
    it 'creates a client with valid parameters' do
      expect(client).to be_a(described_class)
      expect(client.base_url).to eq(base_url)
      expect(client.auth_token).to eq(auth_token)
    end

    it 'raises ValidationException with empty base_url' do
      expect { described_class.new('', auth_token) }.to raise_error(Laneful::ValidationException)
    end

    it 'raises ValidationException with empty auth_token' do
      expect { described_class.new(base_url, '') }.to raise_error(Laneful::ValidationException)
    end

    it 'raises ValidationException with nil base_url' do
      expect { described_class.new(nil, auth_token) }.to raise_error(Laneful::ValidationException)
    end

    it 'raises ValidationException with nil auth_token' do
      expect { described_class.new(base_url, nil) }.to raise_error(Laneful::ValidationException)
    end

    it 'raises ValidationException with invalid URL' do
      expect { described_class.new('invalid-url', auth_token) }.to raise_error(Laneful::ValidationException)
    end
  end

  describe '#send_email' do
    let(:email) do
      Laneful::Email::Builder.new
                             .from(Laneful::Address.new('sender@example.com'))
                             .to(Laneful::Address.new('recipient@example.com'))
                             .subject('Test Email')
                             .text_content('This is a test email.')
                             .build
    end

    context 'with successful response' do
      before do
        stub_request(:post, "#{base_url}/v1/email/send")
          .with(
            body: hash_including('emails' => array_including(hash_including('from', 'to', 'subject'))),
            headers: {
              'Authorization' => "Bearer #{auth_token}",
              'Content-Type' => 'application/json',
              'Accept' => 'application/json',
              'User-Agent' => 'laneful-ruby/1.0.1'
            }
          )
          .to_return(status: 200, body: '{"status": "accepted"}')
      end

      it 'sends email successfully' do
        response = client.send_email(email)
        expect(response).to eq({ 'status' => 'accepted' })
      end
    end

    context 'with API error' do
      before do
        stub_request(:post, "#{base_url}/v1/email/send")
          .to_return(status: 400, body: '{"error": "Invalid email format"}')
      end

      it 'raises ApiException' do
        expect { client.send_email(email) }.to raise_error(Laneful::ApiException)
      end
    end

    context 'with HTTP error' do
      before do
        stub_request(:post, "#{base_url}/v1/email/send")
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises ApiException' do
        expect { client.send_email(email) }.to raise_error(Laneful::ApiException)
      end
    end

    context 'with 404 error' do
      before do
        stub_request(:post, "#{base_url}/v1/email/send")
          .to_return(status: 404, body: 'Not Found')
      end

      it 'raises HttpException' do
        expect { client.send_email(email) }.to raise_error(Laneful::HttpException)
      end
    end
  end

  describe '#send_emails' do
    let(:emails) do
      [
        Laneful::Email::Builder.new
                               .from(Laneful::Address.new('sender@example.com'))
                               .to(Laneful::Address.new('recipient1@example.com'))
                               .subject('Email 1')
                               .text_content('First email content.')
                               .build,
        Laneful::Email::Builder.new
                               .from(Laneful::Address.new('sender@example.com'))
                               .to(Laneful::Address.new('recipient2@example.com'))
                               .subject('Email 2')
                               .text_content('Second email content.')
                               .build
      ]
    end

    context 'with successful response' do
      before do
        stub_request(:post, "#{base_url}/v1/email/send")
          .with(
            body: hash_including('emails' => array_including(
              hash_including('subject' => 'Email 1'),
              hash_including('subject' => 'Email 2')
            ))
          )
          .to_return(status: 200, body: '{"status": "accepted"}')
      end

      it 'sends multiple emails successfully' do
        response = client.send_emails(emails)
        expect(response).to eq({ 'status' => 'accepted' })
      end
    end

    context 'with empty emails list' do
      it 'raises ValidationException' do
        expect { client.send_emails([]) }.to raise_error(Laneful::ValidationException)
      end
    end

    context 'with nil emails list' do
      it 'raises ValidationException' do
        expect { client.send_emails(nil) }.to raise_error(Laneful::ValidationException)
      end
    end

    context 'with invalid email object' do
      it 'raises ValidationException' do
        expect { client.send_emails(['not an email']) }.to raise_error(Laneful::ValidationException)
      end
    end
  end
end
