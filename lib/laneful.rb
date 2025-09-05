# frozen_string_literal: true

require 'json'
require 'httparty'
require 'openssl'
require 'base64'

require_relative 'laneful/version'
require_relative 'laneful/exceptions'
require_relative 'laneful/models'
require_relative 'laneful/client'
require_relative 'laneful/webhooks'

# Laneful Ruby SDK
# A modern Ruby client library for the Laneful email API
module Laneful
  class Error < StandardError; end

  # API version
  API_VERSION = 'v1'

  # Default timeout in seconds
  DEFAULT_TIMEOUT = 30

  # User agent string
  USER_AGENT = 'laneful-ruby/1.0.1'
end
