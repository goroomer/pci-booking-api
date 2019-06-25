# frozen_string_literal: true

module PciBookingApi
  class HttpRequest
    include HTTParty
    base_uri PciBookingApi.base_uri
    debug_output $stdout if ENV['HTTPARTY_DEBUG'].to_i.positive?
  end
end
