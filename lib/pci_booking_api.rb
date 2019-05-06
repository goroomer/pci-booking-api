# frozen_string_literal: true

require 'pci_booking_api/version'

module PciBookingApi
  module_function

  def version
    VERSION
  end

  def setup
    yield self
  end

  def network_timeout
    @network_timeout || 1 # second by default
  end

  def network_timeout=(value)
    @network_timeout = value
  end

  def base_uri
    @base_uri || 'https://service.pcibooking.net/api'
  end

  def base_uri=(value)
    @base_uri = value
  end
end

require 'dotenv/load' if File.exist?('dotenv')
require 'httparty'
require 'pci_booking_api/http_request'
require 'pci_booking_api/error'
require 'pci_booking_api/process_payment_errors/rejection'
require 'pci_booking_api/process_payment_errors/retry'
require 'pci_booking_api/process_payment_errors/fatal'
require 'pci_booking_api/payment_gateways/body_params'
require 'pci_booking_api/payment_gateways/stripe'
require 'pci_booking_api/client'
