# frozen_string_literal: true

module Laneful
  # Main client for communicating with the Laneful email API
  class Client
    include HTTParty

    # Default timeout in seconds
    DEFAULT_TIMEOUT = 30

    attr_reader :base_url, :auth_token, :timeout

    def initialize(base_url, auth_token, timeout: DEFAULT_TIMEOUT)
      @base_url = base_url&.strip
      @auth_token = auth_token&.strip
      @timeout = timeout

      validate_configuration!

      # Configure HTTParty
      self.class.base_uri @base_url
      self.class.default_timeout @timeout
      self.class.headers default_headers
    end

    # Sends a single email
    def send_email(email)
      send_emails([email])
    end

    # Sends multiple emails
    def send_emails(emails)
      validate_emails!(emails)

      request_data = { 'emails' => emails.map(&:to_hash) }
      response = self.class.post("/#{API_VERSION}/email/send", body: request_data.to_json)

      handle_response(response)
    end

    private

    def validate_configuration!
      raise ValidationException, 'Base URL cannot be empty' if base_url.nil? || base_url.empty?

      raise ValidationException, 'Auth token cannot be empty' if auth_token.nil? || auth_token.empty?

      # Basic URL validation
      return if base_url.match?(%r{^https?://})

      raise ValidationException, 'Base URL must be a valid HTTP/HTTPS URL'
    end

    def validate_emails!(emails)
      raise ValidationException, 'Emails list cannot be empty' if emails.nil? || emails.empty?

      emails.each do |email|
        raise ValidationException, 'All emails must be Email instances' unless email.is_a?(Email)
      end
    end

    def default_headers
      {
        'Authorization' => "Bearer #{auth_token}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'User-Agent' => USER_AGENT
      }
    end

    def handle_response(response)
      case response.code
      when 200, 201, 202
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
