# frozen_string_literal: true

module PciBookingApi
  class HttpRequest
    include HTTParty
    base_uri PciBookingApi.base_uri
  end
end
