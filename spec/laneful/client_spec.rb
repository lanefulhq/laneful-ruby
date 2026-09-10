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
              'User-Agent' => Laneful::USER_AGENT
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

    context 'with mail settings' do
      let(:email) { emails.first }

      before do
        stub_request(:post, "#{base_url}/v1/email/send")
          .with(
            body: hash_including(
              'mail_settings' => { 'sandbox_mode' => true, 'return_message_ids' => true }
            )
          )
          .to_return(status: 200, body: '{"status":"accepted","message_ids":["msg-1"]}')
      end

      it 'includes mail_settings in the request body' do
        response = client.send_email(email, Laneful::MailSettings.new(sandbox_mode: true, return_message_ids: true))
        expect(response).to eq({ 'status' => 'accepted', 'message_ids' => ['msg-1'] })
      end
    end
  end

  describe 'organization APIs' do
    let(:org_url) { 'https://api.laneful.net' }
    let(:org_client) { described_class.new(org_url, auth_token) }

    it 'lists unsubscribe groups with query params' do
      stub_request(:get, "#{org_url}/v1/workspaces/21183/unsubscribe-groups?limit=50&search=news")
        .to_return(
          status: 200,
          body: '{"unsubscribe_groups":[{"unsubscribe_group_id":6,"name":"test","created_at":1}],"next_cursor":null}'
        )

      result = org_client.list_unsubscribe_groups(
        21_183,
        Laneful::ListUnsubscribeGroupsParams.new(limit: 50, search: 'news')
      )
      expect(result.unsubscribe_groups.size).to eq(1)
      expect(result.unsubscribe_groups.first.name).to eq('test')
    end

    it 'creates and updates an unsubscribe group' do
      stub_request(:post, "#{org_url}/v1/workspaces/21183/unsubscribe-groups")
        .with(body: { 'name' => 'Newsletters' }.to_json)
        .to_return(status: 201, body: '{"unsubscribe_group":{"unsubscribe_group_id":9,"name":"Newsletters","created_at":2}}')
      stub_request(:patch, "#{org_url}/v1/workspaces/21183/unsubscribe-groups/9")
        .with(body: { 'name' => 'Weekly' }.to_json)
        .to_return(status: 200, body: '{"unsubscribe_group":{"unsubscribe_group_id":9,"name":"Weekly","created_at":2}}')

      created = org_client.create_unsubscribe_group(21_183, 'Newsletters')
      updated = org_client.update_unsubscribe_group(21_183, 9, 'Weekly')
      expect(created.unsubscribe_group_id).to eq(9)
      expect(updated.name).to eq('Weekly')
    end

    it 'lists and gets domains' do
      stub_request(:get, "#{org_url}/v1/workspaces/21183/domains?filter%5Bdomain%5D=dev.laneful.com&limit=50")
        .to_return(
          status: 200,
          body: '{"domains":[{"domain":"dev.laneful.com","verified":true,"dmarc_verified":true}],"pagination":{"next_cursor":null}}'
        )
      stub_request(:get, "#{org_url}/v1/workspaces/21183/domains/dev.laneful.com")
        .to_return(status: 200, body: '{"domain":"dev.laneful.com","verified":true}')

      listed = org_client.list_domains(
        21_183,
        Laneful::ListDomainsParams.new(limit: 50, filter_domain: 'dev.laneful.com')
      )
      domain = org_client.get_domain(21_183, 'dev.laneful.com')
      expect(listed.domains.first.domain).to eq('dev.laneful.com')
      expect(domain.verified).to be true
    end

    it 'creates, updates, verifies, and deletes a domain' do
      stub_request(:post, "#{org_url}/v1/workspaces/21183/domains")
        .with(body: hash_including('domain' => 'mydomain.com', 'tracking' => 'tracking', 'return_path' => 'return-path'))
        .to_return(status: 201, body: '{"domain":"mydomain.com","verified":false}')
      stub_request(:patch, "#{org_url}/v1/workspaces/21183/domains/mydomain.com")
        .with(body: { 'email_track_id' => 'track-1' }.to_json)
        .to_return(status: 200, body: '{"domain":"mydomain.com","email_track_id":"track-1"}')
      stub_request(:post, "#{org_url}/v1/workspaces/21183/domains/mydomain.com/verify")
        .to_return(status: 200, body: '{"domain":"mydomain.com","dmarc_verified":true}')
      stub_request(:delete, "#{org_url}/v1/workspaces/21183/domains/mydomain.com")
        .to_return(status: 200, body: '{"message":"deleted"}')

      created = org_client.create_domain(
        21_183,
        Laneful::CreateDomainRequest.new(domain: 'mydomain.com', tracking: 'tracking', return_path: 'return-path')
      )
      updated = org_client.update_domain(21_183, 'mydomain.com', Laneful::UpdateDomainRequest.new('track-1'))
      verified = org_client.verify_domain(21_183, 'mydomain.com')
      deleted = org_client.delete_domain(21_183, 'mydomain.com')

      expect(created.domain).to eq('mydomain.com')
      expect(updated.email_track_id).to eq('track-1')
      expect(verified.dmarc_verified).to be true
      expect(deleted.message).to eq('deleted')
    end

    it 'omits email_track_id when update leaves it unchanged' do
      stub_request(:patch, "#{org_url}/v1/workspaces/21183/domains/mydomain.com")
        .with(body: '{}')
        .to_return(status: 200, body: '{"domain":"mydomain.com"}')

      org_client.update_domain(21_183, 'mydomain.com', Laneful::UpdateDomainRequest.new)
    end

    it 'lists analytics endpoints with repeated workspace_ids' do
      stub_request(:get, %r{#{Regexp.escape(org_url)}/v1/analytics/radar/domain-spam-ratio\?})
        .to_return(status: 200, body: '{"radar":[]}')
      stub_request(:get, "#{org_url}/v1/analytics/google-postmaster/spam-reports?domain=example.com")
        .to_return(status: 200, body: '{"spam_reports":[]}')
      stub_request(:get, "#{org_url}/v1/analytics/microsoft-snds/reports?limit=50")
        .to_return(status: 200, body: '{"snds_reports":[]}')

      radar = org_client.list_domain_spam_ratio_radar(
        Laneful::ListDomainSpamRatioRadarParams.new(
          workspace_ids: [21_183, 21_197],
          start_date: '2026-09-03',
          end_date: '2026-09-10'
        )
      )
      postmaster = org_client.list_google_postmaster_spam_reports(
        Laneful::ListGooglePostmasterSpamReportsParams.new(domain: 'example.com')
      )
      snds = org_client.list_snds_reports(Laneful::ListSndsReportsParams.new(limit: 50))

      expect(radar.radar).to eq([])
      expect(postmaster.spam_reports).to eq([])
      expect(snds.snds_reports).to eq([])
    end

    it 'serializes repeated workspace_ids without Rails brackets' do
      query = Laneful::ListDomainSpamRatioRadarParams.new(
        workspace_ids: [21_183, 21_197],
        start_date: '2026-09-03'
      ).to_query
      encoded = described_class.default_options[:query_string_normalizer].call(query)
      expect(encoded).to include('workspace_ids=21183')
      expect(encoded).to include('workspace_ids=21197')
      expect(encoded).not_to include('workspace_ids[]')
    end
  end
end
