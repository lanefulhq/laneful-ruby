# frozen_string_literal: true

require 'cgi'
require 'json'

module Laneful
  # Main client for communicating with the Laneful API.
  # Email sending uses a send host (https://your-endpoint.send.laneful.net).
  # Domain, unsubscribe-group, and analytics endpoints use the organization
  # API host (https://api.laneful.net).
  class Client
    include HTTParty

    DEFAULT_TIMEOUT = 30

    # Repeat array keys as workspace_ids=1&workspace_ids=2 (not workspace_ids[]=).
    query_string_normalizer HTTParty::Request::NON_RAILS_QUERY_STRING_NORMALIZER

    attr_reader :base_url, :auth_token, :timeout

    def initialize(base_url, auth_token, timeout: DEFAULT_TIMEOUT)
      @base_url = base_url&.strip
      @auth_token = auth_token&.strip
      @timeout = timeout

      validate_configuration!
    end

    # Sends a single email
    def send_email(email, mail_settings = nil)
      send_emails([email], mail_settings)
    end

    # Sends multiple emails
    def send_emails(emails, mail_settings = nil)
      validate_emails!(emails)

      request_data = { 'emails' => emails.map(&:to_hash) }
      request_data['mail_settings'] = mail_settings.to_hash if mail_settings

      request('POST', '/email/send', request_data)
    end

    # List unsubscribe groups for a workspace.
    # Uses the organization API host (https://api.laneful.net).
    def list_unsubscribe_groups(workspace_id, params = nil)
      ListUnsubscribeGroupsResponse.from_hash(
        request('GET', "/workspaces/#{workspace_id}/unsubscribe-groups", nil, params&.to_query)
      )
    end

    # Create an unsubscribe group in a workspace.
    def create_unsubscribe_group(workspace_id, name)
      data = request('POST', "/workspaces/#{workspace_id}/unsubscribe-groups", { 'name' => name })
      UnsubscribeGroup.from_hash(data['unsubscribe_group'] || data)
    end

    # Update an unsubscribe group.
    def update_unsubscribe_group(workspace_id, unsubscribe_group_id, name)
      data = request(
        'PATCH',
        "/workspaces/#{workspace_id}/unsubscribe-groups/#{unsubscribe_group_id}",
        { 'name' => name }
      )
      UnsubscribeGroup.from_hash(data['unsubscribe_group'] || data)
    end

    # List sending domains for a workspace.
    def list_domains(workspace_id, params = nil)
      ListDomainsResponse.from_hash(
        request('GET', "/workspaces/#{workspace_id}/domains", nil, params&.to_query)
      )
    end

    # Get a single sending domain by name.
    def get_domain(workspace_id, domain)
      Domain.from_hash(
        request('GET', "/workspaces/#{workspace_id}/domains/#{encode_path(domain)}")
      )
    end

    # Create a sending domain in a workspace.
    def create_domain(workspace_id, create_request)
      Domain.from_hash(
        request('POST', "/workspaces/#{workspace_id}/domains", create_request.to_hash)
      )
    end

    # Update a domain's mutable settings (currently the email track).
    def update_domain(workspace_id, domain, update_request)
      Domain.from_hash(
        request(
          'PATCH',
          "/workspaces/#{workspace_id}/domains/#{encode_path(domain)}",
          update_request.to_hash
        )
      )
    end

    # Trigger DNS verification for a domain.
    def verify_domain(workspace_id, domain)
      Domain.from_hash(
        request('POST', "/workspaces/#{workspace_id}/domains/#{encode_path(domain)}/verify")
      )
    end

    # Delete a sending domain from a workspace.
    def delete_domain(workspace_id, domain)
      SuccessResponse.from_hash(
        request('DELETE', "/workspaces/#{workspace_id}/domains/#{encode_path(domain)}")
      )
    end

    # List domains whose spam complaint ratio reached a critical level.
    def list_domain_spam_ratio_radar(params = nil)
      ListDomainSpamRatioRadarResponse.from_hash(
        request('GET', '/analytics/radar/domain-spam-ratio', nil, params&.to_query)
      )
    end

    # List daily Google Postmaster Tools spam-rate reports.
    def list_google_postmaster_spam_reports(params = nil)
      ListGooglePostmasterSpamReportsResponse.from_hash(
        request('GET', '/analytics/google-postmaster/spam-reports', nil, params&.to_query)
      )
    end

    # List daily Microsoft SNDS reports for the organization's sending IPs.
    def list_snds_reports(params = nil)
      ListSndsReportsResponse.from_hash(
        request('GET', '/analytics/microsoft-snds/reports', nil, params&.to_query)
      )
    end

    private

    def validate_configuration!
      raise ValidationException, 'Base URL cannot be empty' if base_url.nil? || base_url.empty?

      raise ValidationException, 'Auth token cannot be empty' if auth_token.nil? || auth_token.empty?

      return if base_url.match?(%r{^https?://})

      raise ValidationException, 'Base URL must be a valid HTTP/HTTPS URL'
    end

    def validate_emails!(emails)
      raise ValidationException, 'Emails list cannot be empty' if emails.nil? || emails.empty?

      emails.each do |email|
        raise ValidationException, 'All emails must be Email instances' unless email.is_a?(Email)
      end
    end

    def default_headers(with_json: true)
      headers = {
        'Authorization' => "Bearer #{auth_token}",
        'Accept' => 'application/json',
        'User-Agent' => USER_AGENT
      }
      headers['Content-Type'] = 'application/json' if with_json
      headers
    end

    def build_url(path)
      "#{base_url.chomp('/')}/#{API_VERSION}/#{path.sub(%r{\A/}, '')}"
    end

    def encode_path(value)
      CGI.escape(value.to_s).gsub('+', '%20')
    end

    def request(method, path, json = nil, query = nil)
      url = build_url(path)

      options = {
        headers: default_headers(with_json: !json.nil?),
        timeout: timeout
      }
      options[:query] = query unless query.nil? || query.empty?
      options[:body] = json.to_json unless json.nil?

      begin
        response = self.class.send(method.downcase, url, options)
      rescue StandardError => e
        raise HttpException.new("HTTP request failed: #{e.message}", 0, e)
      end

      handle_response(response)
    end

    def handle_response(response)
      case response.code
      when 200, 201, 202, 204
        parse_success_response(response)
      when 404
        raise HttpException.new(
          "API endpoint not found (404). Check your base URL. Requested: #{response.request.last_uri}",
          response.code
        )
      else
        handle_error_response(response)
      end
    rescue JSON::ParserError => e
      error_message = "Failed to decode JSON response: #{e.message}. " \
                      "Response body: #{truncate_response_body(response.body)}. " \
                      "URL: #{response.request.last_uri}"
      raise HttpException.new(error_message, response.code, e)
    end

    def parse_success_response(response)
      return {} if response.body.nil? || response.body.strip.empty?

      JSON.parse(response.body)
    end

    def handle_error_response(response)
      error_data = parse_error_response(response)
      error_message = error_data['error'] || 'Unknown API error'
      details = error_data['details'] || ''
      full_error = details.empty? ? error_message : "#{error_message} - #{details}"

      raise ApiException.new(
        "API request failed to #{response.request.last_uri}",
        response.code,
        full_error
      )
    end

    def parse_error_response(response)
      return {} if response.body.nil? || response.body.strip.empty?

      JSON.parse(response.body)
    rescue JSON::ParserError
      { 'error' => 'Invalid JSON response', 'details' => truncate_response_body(response.body) }
    end

    def truncate_response_body(body, max_length: 500)
      return body if body.nil? || body.length <= max_length

      "#{body[0, max_length]}..."
    end
  end
end
