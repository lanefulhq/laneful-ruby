# frozen_string_literal: true

module Laneful
  # Base exception class for all Laneful SDK exceptions
  class LanefulException < StandardError
    def initialize(message = nil, cause = nil)
      super(message)
      @cause = cause
    end

    attr_reader :cause
  end

  # Exception thrown when input validation fails
  class ValidationException < LanefulException
    def initialize(message = nil, cause = nil)
      super
    end
  end

  # Exception thrown when the API returns an error response
  class ApiException < LanefulException
    attr_reader :status_code, :error_message

    def initialize(message = nil, status_code = nil, error_message = nil, cause: nil)
      super(message, cause)
      @status_code = status_code
      @error_message = error_message
    end
  end

  # Exception thrown when HTTP communication fails
  class HttpException < LanefulException
    attr_reader :status_code

    def initialize(message = nil, status_code = nil, cause = nil)
      super(message, cause)
      @status_code = status_code
    end
  end
end
