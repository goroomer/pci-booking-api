# frozen_string_literal: true

module PciBookingApi
  module PaymentGateways
    class BodyParams
      def initialize(params = {})
        @operation = params[:operation].to_s
        @card_token = params[:card].to_s
        @reference_number = params[:reference].to_s
        @gateway_ref = params[:gateway_ref_id].to_s
        if params[:amount].to_f.positive?
          @amount = params[:amount].to_f
        else
          PciBookingApi::Error.throw 'The amount of the transaction is invalid', caller
        end
        @currency = params[:currency].to_s.scan(/[a-zA-Z]/).empty? ? 'USD' : params[:currency]
        @first_name = params[:payer_first_name].to_s
        @last_name = params[:payer_last_name].to_s
        @email = params[:payer_email].to_s
        @phone = params[:payer_phone].to_s
        @address = params[:payer_address].to_s
        @post_code = params[:payer_post_code].to_s
        @city = params[:payer_city].to_s
        @state = params[:payer_state].to_s
        @country = params[:payer_country_code].to_s
      end

      def to_h
        {
          OperationType: @operation,
          cardToken: @card_token,
          myRef: @reference_number,
          Amount: @amount,
          Currency: @currency,
          GatewayReference: @gateway_ref,
          PayerDetails: {
            FirstName: @first_name,
            LastName: @last_name,
            Email: @email,
            Phone: @phone,
            Address1: @address,
            PostCode: @post_code,
            City: @city,
            StateProvince: @state,
            CountryCode: @country
          }
        }
      end
    end
  end
end
