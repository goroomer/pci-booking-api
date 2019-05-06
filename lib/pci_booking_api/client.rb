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

    def process_payment(body_params: {})
      HttpRequest.headers 'Content-Type' => 'application/json'

      provider = supported_gateways(body_params[:gateway_name]).new(options: body_params)
      @options[:body] = provider.request_payload.to_json
      response = HttpRequest.post '/paymentGateway', @options
      Error.throw 'Authentication failure, cannot proceed with the payment', caller if response.unauthorized?

      if response.ok?
        process_payment_operation response.parsed_response
      else
        error_hash = response.parsed_response.fetch('ErrorBlock', {})
        messages = ["Status code: #{error_hash['code']}", error_hash.fetch('message', '').to_s]
        Error.throw messages.join(' | '), caller
      end
    end

    private

    def supported_gateways(name = '')
      {
        'Stripe' => PaymentGateways::Stripe
      }.fetch(name, PaymentGateways::Stripe)
    end

    def process_payment_operation(response = {})
      message = "Code: #{response['GatewayResultCode']}, Reason: #{response['GatewayResultDescription']}"

      case response['OperationResultCode']
      when 'Rejected' then
        ProcessPaymentErrors::Rejection.throw message, caller
      when 'TemporaryFailure' then
        ProcessPaymentErrors::Retry.throw
      when 'FatalFailure' then
        ProcessPaymentErrors::Fatal.trow message, caller
      else
        {
          gateway_name: response['GatewayName'].to_s,
          gateway_ref_id: response['GatewayReference'].to_s,
          amount: response['Amount'].to_f,
          currency: response['Currency'].to_s
        }
      end
    end
  end
end
