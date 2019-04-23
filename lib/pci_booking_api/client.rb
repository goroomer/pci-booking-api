# frozen_string_literal: true

module PciBookingApi
  class Client
    def initialize(api_key: ENV['PCI_BOOKING_API_KEY'])
      HttpRequest.headers 'Authorization' => "APIKEY #{api_key}"
      @options = { body: {}, timeout: PciBookingApi.network_timeout }
    end

    def authenticate
      response = HttpRequest.post '/accounts/authenticate', @options
      Error.throw 'Failed to authenticate' if response.unauthorized?
      response.code
    end

    def payment_gateways
      response = HttpRequest.get '/paymentGateway', @options
      if response.ok?
        response.parsed_response
      else
        Error.throw 'Failed to get supported payment providers'
      end
    end
  end
end
