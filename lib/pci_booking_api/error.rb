# frozen_string_literal: true

module PciBookingApi
  class Error < StandardError
    def self.throw(message = "#{self.class.name} failed!")
      raise self, message
    end
  end
end
