# frozen_string_literal: true

module PciBookingApi
  module PaymentGateways
    class Stripe
      def initialize(options: {})
        @env_name = options[:env_name].to_s
        @body_params = BodyParams.new options
      end

      def request_payload
        to_h
      end

      private

      def to_h
        hash = @body_params.to_h
        hash[:PaymentGateway] = {
          Name: 'Stripe',
          Credentials: {
            APIKey: ENV[@env_name.to_s]
          }
        }
        hash
      end
    end
  end
end
