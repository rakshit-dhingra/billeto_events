module Billetto
  class Client
    BASE_URL = "https://api.billetto.com/v3".freeze

    class Error < StandardError; end
    class AuthenticationError < Error; end
    class RateLimitError < Error; end
    class NotFoundError < Error; end

    def initialize(api_key: Rails.application.credentials.dig(:billetto, :api_key))
      @connection = build_connection(api_key)
    end

    def list_events(page: 1, per_page: 20)
      response = connection.get("/events/public", {
        page: page,
        per_page: per_page
      })
      parse(response)
    rescue Faraday::UnauthorizedError
      raise AuthenticationError, "Invalid Billetto API key"
    rescue Faraday::TooManyRequestsError
      raise RateLimitError, "Billetto API rate limit exceeded"
    rescue Faraday::ResourceNotFound
      raise NotFoundError
    rescue Faraday::Error => e
      raise Error, "Billetto API error: #{e.message}"
    end

    private

    attr_reader :connection

    def build_connection(api_key)
      Faraday.new(BASE_URL) do |f|
        f.request  :retry, max: 3, interval: 1.0,
                            retry_statuses: [429, 503],
                            exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed]
        f.response :raise_error
        f.headers["X-Api-Key"] = api_key
        f.headers["Content-Type"] = "application/json"
        f.headers["Accept"] = "application/json"
      end
    end

    def parse(response)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end