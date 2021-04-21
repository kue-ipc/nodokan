ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'base64'

module FixtureAddressHelper
  def ipv4_address(address)
    '!!binary "' +
    Base64.strict_encode64(IPAddress::IPv4.new(address).data) +
    '"'
  end

  def ipv6_address(address)
    '!!binary "' +
    Base64.strict_encode64(IPAddress::IPv6.new(address).data) +
    '"'
  end

  def mac_address(address)
    '!!binary "' +
    Base64.strict_encode64([address.delete('-:')].pack('H12')) +
    '"'
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureAddressHelper

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
