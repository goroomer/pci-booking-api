# frozen_string_literal: true

RSpec.describe PciBookingApi::Client, type: :plain_ruby_class do
  subject { described_class }

  describe '#authenticate' do
    context 'with wrong API KEY' do
      it 'should raise PciBookingApi::Error' do
        instance = subject.new api_key: SecureRandom.hex
        expect { instance.authenticate }.to raise_error(PciBookingApi::Error, 'Failed to authenticate')
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
    it 'should have Stripe as one of options' do
      if ENV['PCI_BOOKING_API_KEY'].nil?
        response_mock = double(HTTParty::Response, ok?: true)
        allow(PciBookingApi::HttpRequest).to receive(:get).and_return(response_mock)
      end

      hash = subject.new.payment_gateways.find { |h| h['Name'].casecmp('stripe').zero? }
      expect(hash).not_to be nil
    end

    context 'when responded not with 200 OK' do
      it 'should raise PciBookingApi::Error' do
        response_mock = double(HTTParty::Response, ok?: false)
        allow(PciBookingApi::HttpRequest).to receive(:get).and_return(response_mock)

        expect { subject.new.payment_gateways }.to raise_error(PciBookingApi::Error,
                                                               'Failed to get supported payment providers')
      end
    end
  end
end
