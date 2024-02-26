ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "base64"

module FixtureAddressHelper
  def ipv4_address(address)
    "!!binary \"#{Base64.strict_encode64(IPAddr.new(address).hton)}\""
  end

  def ipv6_address(address)
    "!!binary \"#{Base64.strict_encode64(IPAddr.new(address).hton)}\""
  end

  def mac_address(address)
    "!!binary \"#{Base64.strict_encode64([address.delete('-:')].pack('H12'))}\""
  end

  def duid(address)
    "!!binary \"#{Base64.strict_encode64([address.delete('-:')].pack('H*'))}\""
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

module SignInAdmin
  def self.included(klass)
    klass.include Devise::Test::IntegrationHelpers
    klass.setup do
      sign_in users(:admin)
    end
  end
end

module SignInUser
  def self.included(klass)
    klass.include Devise::Test::IntegrationHelpers
    klass.setup do
      sign_in users(:user)
    end
  end
end
