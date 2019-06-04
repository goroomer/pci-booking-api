module PciBookingApi
  class ClientStub < Client
    # To use this stub just add a header to the book request
    # req['X-Card-Token-Url'] = ''
    # The options are :  PreAuthRejected, PreAuthTemporaryFailure, PreAuthFatalFailure
    #                    CaptureRejected, CaptureTemporaryFailure, CaptureFatalFailure
    # Any other Value will respond with success
    def process_payment(body_params: {})

      operation_response = {
          gateway_name: body_params['gateway_name'].to_s,
          gateway_ref_id: 'GatewayReference',
          amount: body_params['amount'].to_f,
          currency: body_params['currency'].to_s
      }

      case "#{body_params[:card]}"
      when "#{body_params[:operation]}Rejected" then
        ProcessPaymentErrors::Rejection.throw "card_error #{body_params[:operation]}Rejected", caller
      when "#{body_params[:operation]}TemporaryFailure" then
        ProcessPaymentErrors::Retry.throw
      when "#{body_params[:operation]}FatalFailure" then
        ProcessPaymentErrors::Fatal.throw "card_error #{body_params[:operation]}FatalFailure", caller
      else
        operation_response
      end
    end

  end
end