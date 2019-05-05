# frozen_string_literal: true

module PciBookingApi
  class Error < StandardError
    def self.throw(message = 'Something went wrong', callbacks = [])
      raise self, message, callbacks
    end
  end
end
