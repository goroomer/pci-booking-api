# frozen_string_literal: true

RSpec.describe PciBookingApi::Client, type: :plain_ruby_class do
  subject { described_class }

  describe '#authenticate' do
    context 'when authorization header is invalid' do
      it 'should raise PciBookingApi::Error' do
        client = subject.new api_key: SecureRandom.hex
        expect { client.authenticate }.to raise_error(PciBookingApi::Error, 'Failed to authenticate')
      end
    end

    context 'with right API KEY' do
      it 'should return HTTP code 204' do
        if ENV['PCI_BOOKING_API_KEY'].nil?
          response_mock = double(HTTParty::Response, code: 204, unauthorized?: false)
          allow(PciBookingApi::HttpRequest).to receive(:post).and_return(response_mock)
        end
        expect(subject.new.authenticate).to eq 204
      end
    end
  end

  describe '#payment_gateways' do
    it 'should return Stripe as one of options' do
      hash = subject.new.payment_gateways.find { |h| h['Name'].casecmp('stripe').zero? }
      expect(hash).not_to be nil
    end

    context 'when response code is not 200 OK' do
      it 'should raise PciBookingApi::Error' do
        response_mock = double(HTTParty::Response, ok?: false)
        allow(PciBookingApi::HttpRequest).to receive(:get).and_return(response_mock)

        expect { subject.new.payment_gateways }.to raise_error(PciBookingApi::Error,
                                                               'Failed to get supported payment providers')
      end
    end
  end

  describe '#process_payment' do
    let(:payload) do
      {
        env_name: 'STRIPE_SECRET_KEY',
        operation: 'PreAuth',
        card: "https://secure.pcibooking.net/api/payments/paycard/#{SecureRandom.hex}",
        reference: '12345',
        amount: rand(100..1000),
        currency: nil,
        gateway_ref_id: nil,
        payer_first_name: 'Test',
        payer_last_name: 'Test',
        payer_email: 'test@example.com',
        payer_phone: '+1-202-555-0123',
        payer_address: '1359 Luke Lane',
        payer_post_code: '73069',
        payer_city: 'Norman',
        payer_state: 'Oklahoma',
        payer_country_code: 'USA'
      }
    end

    context 'when authorization header is invalid' do
      it 'should raise PciBookingApi::Error' do
        client = subject.new api_key: SecureRandom.hex
        expect { client.process_payment(body_params: payload) }
          .to raise_error(PciBookingApi::Error, 'Authentication failure, cannot proceed with the payment')
      end
    end

    context 'when request payload is invalid' do
      it 'should raise PciBookingApi::Error' do
        if ENV['PCI_BOOKING_API_KEY'].nil?
          response_mock = double(HTTParty::Response, unauthorized?: false, ok?: false,
                                 parsed_response: { 'ErrorBlock' => {
                                   'code' => -125, 'message' => 'Bad input data'
                                 } })
          allow(PciBookingApi::HttpRequest).to receive(:post).and_return(response_mock)
        end
        payload.delete(:card)
        expect { subject.new.process_payment(body_params: payload) }
          .to raise_error(PciBookingApi::Error, 'Status code: -125 | Bad input data')
      end
    end

    context 'when operation has rejected' do
      it 'should raise PciBookingApi::ProcessPaymentErrors::Rejection' do
        response_mock = double(HTTParty::Response,
                               unauthorized?: false, ok?: true,
                               parsed_response: {
                                 'OperationType' => 'PreAuth',
                                 'OperationResultCode' => 'Rejected',
                                 'GatewayResultDescription' => '[card_error] test'
                               })
        allow(PciBookingApi::HttpRequest).to receive(:post).and_return(response_mock)
        expect { subject.new.process_payment(body_params: payload) }
          .to raise_error(PciBookingApi::ProcessPaymentErrors::Rejection,
                          'Operation: PreAuth, Desc: [card_error] test')
      end
    end

    context 'when operation must be retried' do
      it 'should raise PciBookingApi::ProcessPaymentErrors::Retry' do
        response_mock = double(HTTParty::Response,
                               unauthorized?: false, ok?: true,
                               parsed_response: { 'OperationResultCode' => 'TemporaryFailure' })
        allow(PciBookingApi::HttpRequest).to receive(:post).and_return(response_mock)
        expect { subject.new.process_payment(body_params: payload) }
          .to raise_error(PciBookingApi::ProcessPaymentErrors::Retry)
      end
    end

    context 'when operation resulted in fatal error' do
      it 'should raise PciBookingApi::ProcessPaymentErrors::Retry' do
        response_mock = double(HTTParty::Response,
                               unauthorized?: false, ok?: true,
                               parsed_response: { 'OperationResultCode' => 'FatalFailure' })
        allow(PciBookingApi::HttpRequest).to receive(:post).and_return(response_mock)
        expect { subject.new.process_payment(body_params: payload) }
          .to raise_error(PciBookingApi::ProcessPaymentErrors::Fatal)
      end
    end

    context 'when operation was successful' do
      it 'should return predefined hash extracted from the response' do
        response_mock = double(HTTParty::Response,
                               unauthorized?: false, ok?: true,
                               parsed_response: { 'OperationResultCode' => 'Success' })
        allow(PciBookingApi::HttpRequest).to receive(:post).and_return(response_mock)
        expect(subject.new.process_payment(body_params: payload)).to eq(gateway_name: '',
                                                                        gateway_ref_id: '',
                                                                        amount: 0.0,
                                                                        currency: '')
      end
    end
  end
end
