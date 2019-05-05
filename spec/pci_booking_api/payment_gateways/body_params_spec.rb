# frozen_string_literal: true

RSpec.describe PciBookingApi::PaymentGateways::BodyParams, type: :plain_ruby_class do
  subject { described_class }

  let(:payload) do
    {
      operation: nil,
      card: nil,
      reference: nil,
      amount: nil,
      currency: nil,
      gateway_ref_id: nil,
      payer_first_name: nil,
      payer_last_name: nil,
      payer_email: nil,
      payer_phone: nil,
      payer_address: nil,
      payer_post_code: nil,
      payer_city: nil,
      payer_state: nil,
      payer_country_code: nil
    }
  end

  describe '#new' do
    context 'when amount is invalid' do
      it 'should raise PciBookingApi::Error' do
        expect { subject.new payload }.to raise_error(PciBookingApi::Error, 'The amount of the transaction is invalid')
      end

      it 'should raise PciBookingApi::Error' do
        payload[:amount] = 0
        expect { subject.new payload }.to raise_error(PciBookingApi::Error, 'The amount of the transaction is invalid')
      end

      it 'should raise PciBookingApi::Error' do
        payload[:amount] = -10.0
        expect { subject.new payload }.to raise_error(PciBookingApi::Error, 'The amount of the transaction is invalid')
      end
    end

    context 'when currency is invalid' do
      before(:each) { payload[:amount] = rand(100..100) }

      it 'should set USD by default' do
        expect(subject.new(payload).to_h).to include Currency: 'USD'
      end

      it 'should set USD by default' do
        payload[:currency] = ''
        expect(subject.new(payload).to_h).to include Currency: 'USD'
      end

      it 'should set USD by default' do
        payload[:currency] = ' '
        expect(subject.new(payload).to_h).to include Currency: 'USD'
      end

      it 'should set USD by default' do
        payload[:currency] = '1'
        expect(subject.new(payload).to_h).to include Currency: 'USD'
      end
    end
  end
end
